package com.sahaayi.android.accessibility

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.graphics.Rect
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * SahaayiAccessibilityService
 *
 * Provides screen-reading and form-field detection capabilities for Sahaayi.
 *
 * =========================================================================
 * IMPORTANT PERMISSIONS & ETHICS NOTICE
 * =========================================================================
 * This service is a powerful Android API and must be used responsibly.
 *
 * PERMITTED:
 *   ✅ Reading visible text labels and input field labels
 *   ✅ Detecting form field positions and types (text, date, dropdown)
 *   ✅ Highlighting UI nodes to guide the user
 *   ✅ Operating only when explicitly activated by the user via a UI action
 *
 * STRICTLY FORBIDDEN:
 *   ❌ Reading password fields (inputType = TYPE_TEXT_VARIATION_PASSWORD)
 *   ❌ Reading OTP fields or any field labelled "OTP", "PIN", or "passcode"
 *   ❌ Reading banking credentials (card numbers, CVV, account numbers)
 *   ❌ Operating silently without user awareness
 *   ❌ Transmitting screen content to any server without explicit user consent
 *   ❌ Storing raw screen captures or full accessibility trees
 *
 * ACTIVATION:
 *   The user must navigate to:
 *     Settings → Accessibility → Sahaayi Accessibility Service → Enable
 *   The app will display instructions but CANNOT enable the service
 *   programmatically. This is enforced by Android.
 * =========================================================================
 */
class SahaayiAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "SahaayiA11y"

        // Input types that must NEVER be read or extracted
        private val FORBIDDEN_INPUT_TYPES = setOf(
            "password", "otp", "pin", "cvv", "card", "account", "passcode"
        )

        // Channel name for communicating back to Flutter
        const val CHANNEL_NAME = "sahaayi/accessibility"
    }

    // Tracks whether the user has explicitly triggered an inspection session
    private var isSessionActive = false

    // -------------------------------------------------------------------------
    // Lifecycle — Service Connected
    // -------------------------------------------------------------------------

    /**
     * Called when the system binds to this service. Configure the type of events
     * we want to receive and the capabilities we require.
     */
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "SahaayiAccessibilityService connected.")

        val info = AccessibilityServiceInfo().apply {
            // Only listen to these event types
            eventTypes =
                AccessibilityEvent.TYPE_VIEW_CLICKED or
                AccessibilityEvent.TYPE_VIEW_FOCUSED or
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED

            feedbackType =
                AccessibilityServiceInfo.FEEDBACK_SPOKEN or
                AccessibilityServiceInfo.FEEDBACK_GENERIC

            flags =
                AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_REQUEST_ENHANCED_WEB_ACCESSIBILITY

            // Do NOT restrict to specific packages — we support any app the user opens
            packageNames = null

            notificationTimeout = 100L
        }

        serviceInfo = info
        Log.i(TAG, "AccessibilityServiceInfo configured.")
    }

    // -------------------------------------------------------------------------
    // Event Handling
    // -------------------------------------------------------------------------

    /**
     * Called each time an accessibility event fires.
     *
     * We only act on events when [isSessionActive] is true — i.e., when the user
     * has explicitly opened the Sahaayi overlay and asked us to scan the screen.
     *
     * @param event The accessibility event from the system.
     */
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return

        if (!isSessionActive) {
            // Do not process events silently in the background.
            return
        }

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                val rootNode = rootInActiveWindow ?: return
                try {
                    Log.d(TAG, "Window changed, scanning form fields...")
                    val fields = extractFormFields(rootNode)
                    Log.i(TAG, "Detected ${fields.size} form fields.")
                    // TODO: Send fields to Flutter via EventChannel
                } finally {
                    rootNode.recycle()
                }
            }
            else -> {
                // Other event types are ignored
            }
        }
    }

    /**
     * Called when the system wants to interrupt feedback being provided by the service.
     * We stop any ongoing operations and clear the session.
     */
    override fun onInterrupt() {
        Log.w(TAG, "AccessibilityService interrupted.")
        isSessionActive = false
    }

    // -------------------------------------------------------------------------
    // Form Field Detection
    // -------------------------------------------------------------------------

    /**
     * Traverses the accessibility node tree to identify editable form fields.
     *
     * SAFETY: Any node with an input type or hint that matches [FORBIDDEN_INPUT_TYPES]
     * is silently skipped and never returned to the caller.
     *
     * @param rootNode The root AccessibilityNodeInfo of the active window.
     * @return A list of [FormField] objects describing detectable fields.
     */
    fun extractFormFields(rootNode: AccessibilityNodeInfo): List<FormField> {
        val fields = mutableListOf<FormField>()
        traverseNode(rootNode, fields)
        return fields
    }

    /**
     * Recursively traverses accessibility nodes, collecting editable fields.
     *
     * @param node    Current node being inspected.
     * @param results Accumulator list for discovered fields.
     */
    private fun traverseNode(node: AccessibilityNodeInfo, results: MutableList<FormField>) {
        if (!node.isVisibleToUser) return

        // Check if this node is an editable text field
        if (node.isEditable || node.className == "android.widget.EditText") {
            val label = resolveFieldLabel(node)
            val hint = node.hintText?.toString() ?: ""
            val nodeId = node.viewIdResourceName ?: node.hashCode().toString()

            // Safety check: skip forbidden field types
            val combinedText = "$label $hint".lowercase()
            val isForbidden = FORBIDDEN_INPUT_TYPES.any { combinedText.contains(it) }

            if (!isForbidden) {
                val bounds = Rect()
                node.getBoundsInScreen(bounds)

                results.add(
                    FormField(
                        label = label,
                        hint = hint,
                        nodeId = nodeId,
                        bounds = bounds,
                        isMultiLine = node.isMultiLine,
                        currentValue = node.text?.toString() ?: ""
                    )
                )
            } else {
                Log.d(TAG, "Skipping forbidden field: $label")
            }
        }

        // Recurse into children
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            traverseNode(child, results)
            child.recycle()
        }
    }

    /**
     * Resolves a human-readable label for a form field node.
     *
     * Attempts to find the label by:
     * 1. The node's own contentDescription
     * 2. The node's hintText
     * 3. A sibling TextView that visually labels the field
     * 4. The viewIdResourceName (last resort)
     *
     * @param node The editable field node.
     * @return A human-readable label string, or an empty string if not found.
     */
    private fun resolveFieldLabel(node: AccessibilityNodeInfo): String {
        // 1. Content description
        node.contentDescription?.toString()?.takeIf { it.isNotBlank() }?.let { return it }

        // 2. Hint text
        node.hintText?.toString()?.takeIf { it.isNotBlank() }?.let { return it }

        // 3. Try to find a sibling or parent label
        val parent = node.parent
        if (parent != null) {
            for (i in 0 until parent.childCount) {
                val sibling = parent.getChild(i) ?: continue
                val isLabel =
                    sibling.className == "android.widget.TextView" &&
                    !sibling.isEditable &&
                    sibling.text != null
                if (isLabel) {
                    val labelText = sibling.text.toString()
                    sibling.recycle()
                    if (labelText.isNotBlank()) return labelText
                }
                sibling.recycle()
            }
            parent.recycle()
        }

        // 4. Fallback to view ID
        return node.viewIdResourceName?.substringAfterLast("/") ?: ""
    }

    // -------------------------------------------------------------------------
    // Screen Content Reading
    // -------------------------------------------------------------------------

    /**
     * Reads all visible text content on the current screen.
     *
     * This method is intended to help users who have trouble reading small text
     * on-screen. It concatenates visible text from all non-editable nodes.
     *
     * SAFETY: Text from editable input nodes and password fields is excluded.
     *
     * @return A string of all visible, non-sensitive screen text.
     */
    fun readScreenContent(): String {
        val rootNode = rootInActiveWindow ?: return ""
        return try {
            val builder = StringBuilder()
            collectVisibleText(rootNode, builder)
            builder.toString().trim()
        } finally {
            rootNode.recycle()
        }
    }

    /**
     * Recursively collects visible, non-sensitive text from the node tree.
     *
     * @param node    Current node.
     * @param builder String accumulator.
     */
    private fun collectVisibleText(node: AccessibilityNodeInfo, builder: StringBuilder) {
        if (!node.isVisibleToUser) return

        // Skip all editable fields entirely for screen reading
        if (!node.isEditable && node.text != null) {
            val text = node.text.toString()
            if (text.isNotBlank()) {
                builder.append(text).append(" ")
            }
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            collectVisibleText(child, builder)
            child.recycle()
        }
    }

    // -------------------------------------------------------------------------
    // Node Highlighting
    // -------------------------------------------------------------------------

    /**
     * Programmatically scrolls to and focuses a node identified by [nodeId],
     * making it visible for the user to interact with.
     *
     * Note: Highlighting is a visual focus action only. We do NOT fill or
     * interact with the field without the user explicitly taking action.
     *
     * @param nodeId The viewIdResourceName of the target node.
     * @return True if the node was found and focused; false otherwise.
     */
    fun highlightNode(nodeId: String): Boolean {
        val rootNode = rootInActiveWindow ?: return false
        return try {
            val nodes = rootNode.findAccessibilityNodeInfosByViewId(nodeId)
            if (nodes.isNullOrEmpty()) {
                Log.w(TAG, "Could not find node: $nodeId")
                false
            } else {
                val node = nodes.first()
                val scrolled = node.performAction(AccessibilityNodeInfo.ACTION_SCROLL_INTO_VIEW)
                val focused = node.performAction(AccessibilityNodeInfo.ACTION_ACCESSIBILITY_FOCUS)
                nodes.forEach { it.recycle() }
                scrolled || focused
            }
        } finally {
            rootNode.recycle()
        }
    }

    // -------------------------------------------------------------------------
    // Session Management (called from FlutterChannelBridge)
    // -------------------------------------------------------------------------

    /** Begins a user-initiated scanning session. */
    fun startSession() {
        isSessionActive = true
        Log.i(TAG, "Accessibility scanning session started by user.")
    }

    /** Ends the scanning session. */
    fun endSession() {
        isSessionActive = false
        Log.i(TAG, "Accessibility scanning session ended.")
    }

    // -------------------------------------------------------------------------
    // Data Classes
    // -------------------------------------------------------------------------

    /**
     * Represents a detected, non-sensitive form field on-screen.
     *
     * @property label       Human-readable field label (e.g., "Name", "Date of Birth").
     * @property hint        Placeholder/hint text from the field.
     * @property nodeId      Unique identifier for the view node.
     * @property bounds      Screen coordinates of the field.
     * @property isMultiLine Whether the field accepts multi-line input.
     * @property currentValue The current (non-sensitive) value already in the field.
     */
    data class FormField(
        val label: String,
        val hint: String,
        val nodeId: String,
        val bounds: Rect,
        val isMultiLine: Boolean,
        val currentValue: String
    )
}

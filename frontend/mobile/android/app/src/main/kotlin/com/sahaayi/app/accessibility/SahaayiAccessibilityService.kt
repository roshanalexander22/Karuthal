package com.sahaayi.app.accessibility

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
 * PERMITTED:
 *   ✅ Reading visible text labels and input field labels
 *   ✅ Detecting form field positions and types
 *   ✅ Highlighting UI nodes to guide the user
 *   ✅ Operating only when explicitly activated by the user
 *
 * STRICTLY FORBIDDEN:
 *   ❌ Reading password fields or OTP/PIN/passcode fields
 *   ❌ Reading banking credentials
 *   ❌ Operating silently in the background
 *   ❌ Storing raw credentials or passwords
 */
class SahaayiAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "SahaayiA11y"

        // Singleton instance for platform channel interaction
        var instance: SahaayiAccessibilityService? = null
            private set

        // Input types that must NEVER be read or extracted
        private val FORBIDDEN_INPUT_TYPES = setOf(
            "password", "otp", "pin", "cvv", "card", "account", "passcode"
        )

        const val CHANNEL_NAME = "sahaayi/accessibility"
    }

    private var isSessionActive = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.i(TAG, "SahaayiAccessibilityService connected.")

        val info = AccessibilityServiceInfo().apply {
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

            packageNames = null
            notificationTimeout = 100L
        }

        serviceInfo = info
        Log.i(TAG, "AccessibilityServiceInfo configured.")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        if (!isSessionActive) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                val rootNode = rootInActiveWindow ?: return
                try {
                    val fields = extractFormFields(rootNode)
                    Log.i(TAG, "Detected ${fields.size} form fields.")
                } finally {
                    rootNode.recycle()
                }
            }
            else -> {}
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "AccessibilityService interrupted.")
        isSessionActive = false
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) {
            instance = null
        }
        Log.i(TAG, "SahaayiAccessibilityService destroyed.")
    }

    fun extractScreenElements(): List<Map<String, Any>> {
        val rootNode = rootInActiveWindow ?: return emptyList()
        return try {
            val fields = extractFormFields(rootNode)
            fields.map { field ->
                mapOf(
                    "nodeId" to field.nodeId,
                    "label" to field.label,
                    "hint" to field.hint,
                    "isMultiLine" to field.isMultiLine,
                    "currentValue" to field.currentValue,
                    "bounds" to mapOf(
                        "left" to field.bounds.left,
                        "top" to field.bounds.top,
                        "right" to field.bounds.right,
                        "bottom" to field.bounds.bottom
                    )
                )
            }
        } finally {
            rootNode.recycle()
        }
    }

    fun injectFieldValue(nodeId: String, text: String): Boolean {
        val rootNode = rootInActiveWindow ?: return false
        return try {
            findAndSetText(rootNode, nodeId, text)
        } finally {
            rootNode.recycle()
        }
    }

    private fun findAndSetText(node: AccessibilityNodeInfo, targetNodeId: String, text: String): Boolean {
        val currentNodeId = node.viewIdResourceName ?: node.hashCode().toString()
        if (currentNodeId == targetNodeId && (node.isEditable || node.className == "android.widget.EditText")) {
            val label = resolveFieldLabel(node)
            val hint = node.hintText?.toString() ?: ""
            val combinedText = "$label $hint".lowercase()
            if (FORBIDDEN_INPUT_TYPES.any { combinedText.contains(it) }) {
                Log.w(TAG, "Refusing to inject value into sensitive field: $currentNodeId")
                return false
            }
            val arguments = android.os.Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
            }
            return node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, arguments)
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val found = findAndSetText(child, targetNodeId, text)
            child.recycle()
            if (found) return true
        }
        return false
    }

    fun extractFormFields(rootNode: AccessibilityNodeInfo): List<FormField> {
        val fields = mutableListOf<FormField>()
        traverseNode(rootNode, fields)
        return fields
    }

    private fun traverseNode(node: AccessibilityNodeInfo, results: MutableList<FormField>) {
        if (!node.isVisibleToUser) return

        if (node.isEditable || node.className == "android.widget.EditText") {
            val label = resolveFieldLabel(node)
            val hint = node.hintText?.toString() ?: ""
            val nodeId = node.viewIdResourceName ?: node.hashCode().toString()

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

        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            traverseNode(child, results)
            child.recycle()
        }
    }

    private fun resolveFieldLabel(node: AccessibilityNodeInfo): String {
        node.labeledBy?.let { labelNode ->
            val text = labelNode.text?.toString()
            labelNode.recycle()
            if (!text.isNullOrBlank()) return text
        }

        node.contentDescription?.toString()?.takeIf { it.isNotBlank() }?.let { return it }
        node.hintText?.toString()?.takeIf { it.isNotBlank() }?.let { return it }

        return "Unnamed Field"
    }

    data class FormField(
        val label: String,
        val hint: String,
        val nodeId: String,
        val bounds: Rect,
        val isMultiLine: Boolean,
        val currentValue: String
    )
}

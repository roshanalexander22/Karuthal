package com.sahaayi.android.autofill

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillContext
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveInfo
import android.service.autofill.SaveRequest
import android.util.Log
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews

/**
 * SahaayiAutofillService
 *
 * Provides form-filling assistance by suggesting verified profile data
 * when the user focuses on form fields in any app.
 *
 * =========================================================================
 * CRITICAL SAFETY CONSTRAINTS — MUST BE FOLLOWED AT ALL TIMES
 * =========================================================================
 *
 * ❌ NEVER fill password fields (inputType = TYPE_TEXT_VARIATION_PASSWORD)
 * ❌ NEVER fill OTP fields (labels containing "OTP", "one-time", "verify")
 * ❌ NEVER fill CVV, CVC, or card number fields
 * ❌ NEVER fill bank account numbers, IFSC codes, or UPI IDs
 * ❌ NEVER automatically submit a form without explicit user action
 * ❌ NEVER invent or fabricate values not present in the user's verified profile
 * ❌ NEVER store field values captured from SaveRequest without user approval
 *
 * ✅ ALWAYS present a confirmation UI (presentation RemoteView) before filling
 * ✅ ALWAYS use only data from the verified personal_profile_fields store
 * ✅ ALWAYS allow the user to dismiss the autofill suggestion
 * ✅ ALWAYS log fill actions to the audit trail
 *
 * =========================================================================
 *
 * ACTIVATION:
 *   Users must navigate to:
 *     Settings → System → Languages & Input → Autofill Service → Sahaayi
 *   The app will display a prompt, but CANNOT activate this programmatically.
 */
class SahaayiAutofillService : AutofillService() {

    companion object {
        private const val TAG = "SahaayiAutofill"

        // Input types and hints that must NEVER be filled
        private val FORBIDDEN_FIELD_HINTS = setOf(
            "password", "passwd", "otp", "one-time", "pin",
            "cvv", "cvc", "card-number", "cardnumber", "account",
            "routing", "ifsc", "upi"
        )

        const val CHANNEL_NAME = "sahaayi/autofill"
    }

    // -------------------------------------------------------------------------
    // Fill Request — Suggest Values to the User
    // -------------------------------------------------------------------------

    /**
     * Called by Android when a form becomes active and needs autofill suggestions.
     *
     * Flow:
     * 1. Parse the fill request to identify form fields (non-sensitive only).
     * 2. Load relevant fields from the user's verified profile.
     * 3. Build a [FillResponse] with [Dataset] objects — each showing a
     *    confirmation presentation before the value is actually placed.
     * 4. The user must tap the suggestion chip to trigger filling.
     *
     * @param request  The system-provided fill request with context.
     * @param cancellationSignal Signal to detect if the request was cancelled.
     * @param callback Callback to deliver the [FillResponse].
     */
    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        Log.d(TAG, "onFillRequest received.")

        if (cancellationSignal.isCanceled) {
            Log.d(TAG, "Fill request was cancelled before processing.")
            return
        }

        try {
            val context: List<FillContext> = request.fillContexts
            val latestStructure = context.lastOrNull()?.structure

            if (latestStructure == null) {
                Log.w(TAG, "No window structure available.")
                callback.onSuccess(null)
                return
            }

            val packageName = latestStructure.activityComponent.packageName
            Log.d(TAG, "Autofill request from package: $packageName")

            // Parse the view hierarchy to find non-sensitive fillable fields
            val fillableFields = parseStructureForFillableFields(latestStructure)

            if (fillableFields.isEmpty()) {
                Log.d(TAG, "No fillable fields found.")
                callback.onSuccess(null)
                return
            }

            // Load matching profile values (stub — replace with repository call)
            val profileValues = loadProfileValues(fillableFields.map { it.hint })

            if (profileValues.isEmpty()) {
                Log.d(TAG, "No matching profile values found.")
                callback.onSuccess(null)
                return
            }

            // Build the dataset with a confirmation presentation
            val dataset = buildDataset(fillableFields, profileValues)

            val fillResponse = FillResponse.Builder()
                .addDataset(dataset)
                .build()

            callback.onSuccess(fillResponse)
            Log.i(TAG, "FillResponse delivered with ${fillableFields.size} field(s).")

        } catch (e: Exception) {
            Log.e(TAG, "Error processing fill request", e)
            callback.onFailure("Fill request failed: ${e.message}")
        }
    }

    // -------------------------------------------------------------------------
    // Save Request — Offer to Save User-Entered Data
    // -------------------------------------------------------------------------

    /**
     * Called by Android when the user submits a form and the system wants to know
     * if Sahaayi should save any entered values.
     *
     * SAFETY: We only offer to save explicitly non-sensitive fields
     * (name, address, etc.). We NEVER offer to save passwords, OTPs, or
     * payment data.
     *
     * The user must explicitly approve saving through a confirmation dialog.
     *
     * @param request  The system-provided save request.
     * @param callback Callback to signal save success or failure.
     */
    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        Log.d(TAG, "onSaveRequest received.")

        try {
            val context = request.fillContexts.lastOrNull()
            if (context == null) {
                callback.onSuccess()
                return
            }

            // TODO: Implement save UI flow
            // 1. Show a bottom sheet asking the user which fields to save
            // 2. Only save values the user explicitly approves
            // 3. Store approved values in the personal_profile_fields table via API
            // 4. Log the save action in audit_logs

            Log.i(TAG, "Save request processed. User approval required (not yet implemented).")
            callback.onSuccess()

        } catch (e: Exception) {
            Log.e(TAG, "Error processing save request", e)
            callback.onFailure("Save request failed: ${e.message}")
        }
    }

    // -------------------------------------------------------------------------
    // Helper: Parse View Structure
    // -------------------------------------------------------------------------

    /**
     * Traverses the [android.app.assist.AssistStructure] to identify editable,
     * non-sensitive form fields.
     *
     * @param structure The assist structure for the active window.
     * @return A list of [FillableField] records for safe fields only.
     */
    private fun parseStructureForFillableFields(
        structure: android.app.assist.AssistStructure
    ): List<FillableField> {
        val results = mutableListOf<FillableField>()

        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            traverseViewNode(windowNode.rootViewNode, results)
        }

        return results
    }

    private fun traverseViewNode(
        node: android.app.assist.AssistStructure.ViewNode,
        results: MutableList<FillableField>
    ) {
        val autofillId = node.autofillId ?: run {
            // Recurse into children anyway
            for (i in 0 until node.childCount) traverseViewNode(node.getChildAt(i), results)
            return
        }

        if (node.isFocusable && node.autofillType != android.view.View.AUTOFILL_TYPE_NONE) {
            val hint = node.hint?.lowercase() ?: ""
            val autofillHints = node.autofillHints?.map { it.lowercase() } ?: emptyList()
            val combinedHints = "$hint ${autofillHints.joinToString(" ")}"

            val isForbidden = FORBIDDEN_FIELD_HINTS.any { combinedHints.contains(it) }

            if (!isForbidden) {
                results.add(
                    FillableField(
                        autofillId = autofillId,
                        hint = hint,
                        autofillHints = autofillHints
                    )
                )
            } else {
                Log.d(TAG, "Skipping forbidden autofill field: $hint")
            }
        }

        for (i in 0 until node.childCount) {
            traverseViewNode(node.getChildAt(i), results)
        }
    }

    // -------------------------------------------------------------------------
    // Helper: Load Profile Values (Stub)
    // -------------------------------------------------------------------------

    /**
     * Retrieves matching profile values for the given field hints.
     *
     * TODO: Replace stub with an actual call to the local encrypted data store
     * (EncryptedSharedPreferences or secure SQLite) which mirrors the user's
     * verified personal_profile_fields.
     *
     * @param hints List of field hint strings.
     * @return Map of hint → profile value.
     */
    private fun loadProfileValues(hints: List<String>): Map<String, String> {
        // STUB: Return empty map until repository is wired up
        // In production:
        //   val repo = ProfileRepository.getInstance(applicationContext)
        //   return repo.getFieldsMatchingHints(hints)
        Log.d(TAG, "loadProfileValues stub called with hints: $hints")
        return emptyMap()
    }

    // -------------------------------------------------------------------------
    // Helper: Build Dataset
    // -------------------------------------------------------------------------

    /**
     * Constructs a [Dataset] that presents a user-visible confirmation chip
     * before placing any values in form fields.
     *
     * @param fields        Fields to be filled.
     * @param profileValues Map of hint → value from the user's profile.
     * @return A [Dataset] with presentation views and autofill values.
     */
    private fun buildDataset(
        fields: List<FillableField>,
        profileValues: Map<String, String>
    ): Dataset {
        val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1).apply {
            setTextViewText(android.R.id.text1, "Fill with Sahaayi profile")
        }

        val builder = Dataset.Builder(presentation)

        for (field in fields) {
            val value = profileValues[field.hint] ?: continue
            builder.setValue(
                field.autofillId,
                AutofillValue.forText(value),
                presentation
            )
        }

        return builder.build()
    }

    // -------------------------------------------------------------------------
    // Data Classes
    // -------------------------------------------------------------------------

    /**
     * Represents a form field that is safe to fill.
     *
     * @property autofillId   Android autofill system identifier for the view.
     * @property hint         The field's hint text (lowercased).
     * @property autofillHints Declared autofill hints from the view.
     */
    data class FillableField(
        val autofillId: AutofillId,
        val hint: String,
        val autofillHints: List<String>
    )
}

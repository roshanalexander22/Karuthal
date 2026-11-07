package com.sahaayi.app.autofill

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
 * CRITICAL SAFETY CONSTRAINTS:
 * ❌ NEVER fill password fields or OTP/PIN fields
 * ❌ NEVER fill CVV, CVC, or card numbers
 * ❌ NEVER automatically submit forms
 * ❌ NEVER invent missing values
 * ✅ ALWAYS require explicit user confirmation before filling
 */
class SahaayiAutofillService : AutofillService() {

    companion object {
        private const val TAG = "SahaayiAutofill"

        private val FORBIDDEN_FIELD_HINTS = setOf(
            "password", "passwd", "otp", "one-time", "pin",
            "cvv", "cvc", "card-number", "cardnumber", "account",
            "routing", "ifsc", "upi"
        )

        const val CHANNEL_NAME = "sahaayi/autofill"
    }

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        Log.d(TAG, "onFillRequest received.")

        if (cancellationSignal.isCanceled) return

        try {
            val context: List<FillContext> = request.fillContexts
            val latestStructure = context.lastOrNull()?.structure

            if (latestStructure == null) {
                callback.onSuccess(null)
                return
            }

            val fillableFields = parseStructureForFillableFields(latestStructure)

            if (fillableFields.isEmpty()) {
                callback.onSuccess(null)
                return
            }

            val profileValues = loadProfileValues(fillableFields.map { it.hint })

            if (profileValues.isEmpty()) {
                callback.onSuccess(null)
                return
            }

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

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        Log.d(TAG, "onSaveRequest received.")
        callback.onSuccess()
    }

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
            }
        }

        for (i in 0 until node.childCount) {
            traverseViewNode(node.getChildAt(i), results)
        }
    }

    private fun loadProfileValues(hints: List<String>): Map<String, String> {
        Log.d(TAG, "loadProfileValues called with hints: $hints")
        return emptyMap()
    }

    private fun buildDataset(
        fields: List<FillableField>,
        profileValues: Map<String, String>
    ): Dataset {
        val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1).apply {
            setTextViewText(android.R.id.text1, "സഹായി പ്രൊഫൈൽ വഴി പൂരിപ്പിക്കുക (Fill with Sahaayi)")
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

    data class FillableField(
        val autofillId: AutofillId,
        val hint: String,
        val autofillHints: List<String>
    )
}

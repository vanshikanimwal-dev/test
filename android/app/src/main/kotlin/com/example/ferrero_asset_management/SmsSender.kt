//important code
package com.example.ferrero_asset_management // Make sure this matches your package

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build // For checking Android version
import android.telephony.SmsManager // For sending SMS
import android.util.Log // For logging
import androidx.core.content.ContextCompat // For checking permissions

class SmsSender(private val context: Context) {

    private val TAG = "SmsSender"

    fun hasSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.SEND_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun sendSms(phoneNumber: String, message: String): Boolean {
        if (!hasSmsPermission()) {
            Log.e(TAG, "SMS permission not granted. Cannot send SMS.")
            return false
        }

        return try {
            val smsManager: SmsManager =
            // Use getSystemService for API 23 (Marshmallow) and higher
                // For API 31 (Android 12) and above, getSystemService is the preferred way to get SmsManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // S is API 31
                    context.getSystemService(SmsManager::class.java)
                } else {
                    // Fallback for older API versions
                    @Suppress("DEPRECATION") // Suppress deprecation warning for getDefault()
                    SmsManager.getDefault()
                }

            // SmsManager automatically handles message splitting for long messages
            // You don't need to manually check message.length > 160 unless you have specific requirements.
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)

            Log.d(TAG, "SMS sent successfully to $phoneNumber")
            true

        } catch (e: Exception) {
            Log.e(TAG, "SMS sending failed: ${e.message}", e)
            e.printStackTrace() // Print stack trace for detailed error
            false
        }
    }
}
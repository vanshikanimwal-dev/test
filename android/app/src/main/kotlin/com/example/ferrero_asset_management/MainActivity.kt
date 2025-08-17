//////
//////
//////package com.example.ferrero_asset_management
//////
//////import android.Manifest // For Manifest.permission.SEND_SMS
//////import android.content.Context // For applicationContext
//////import android.content.pm.PackageManager // For PackageManager.PERMISSION_GRANTED
//////import androidx.annotation.NonNull // For @NonNull annotation
//////import androidx.core.app.ActivityCompat // For ActivityCompat.requestPermissions
//////import io.flutter.embedding.android.FlutterActivity // Base class for Flutter activity
//////import io.flutter.embedding.engine.FlutterEngine // For configuring Flutter engine
//////import io.flutter.plugin.common.MethodChannel // For MethodChannel communication
//////// Make sure SmsSender.kt is in the same package path:
//////// android/app/src/main/kotlin/com/example/ferrero_asset_management/SmsSender.kt
//////import com.example.ferrero_asset_management.SmsSender
//////
//////class MainActivity: FlutterActivity() {
//////
//////    private val CHANNEL = "com.ferrero.asset_management/sms" // Must match your Dart channel name
//////    private val SEND_SMS_PERMISSION_REQUEST_CODE = 101
//////
//////    private var permissionResultCallback: MethodChannel.Result? = null // Nullable result callback
//////
//////    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//////        super.configureFlutterEngine(flutterEngine) // Call super method first
//////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
//////                call, result ->
//////            when (call.method) {
//////                "sendSms" -> {
//////                    val phoneNumber = call.argument<String>("phoneNumber")
//////                    val message = call.argument<String>("message")
//////
//////                    if (phoneNumber == null || message == null) {
//////                        result.error("INVALID_ARGUMENTS", "Phone number or message cannot be null", null)
//////                        return@setMethodCallHandler
//////                    }
//////
//////                    val smsSender = SmsSender(applicationContext) // Use applicationContext
//////
//////                    if (smsSender.hasSmsPermission()) {
//////                        val success = smsSender.sendSms(phoneNumber, message)
//////                        result.success(success)
//////                    } else {
//////                        // Permission not granted, request it and store the result callback
//////                        permissionResultCallback = result // Store the result callback
//////                        ActivityCompat.requestPermissions(
//////                            this, // Activity context
//////                            arrayOf(Manifest.permission.SEND_SMS),
//////                            SEND_SMS_PERMISSION_REQUEST_CODE
//////                        )
//////                    }
//////                }
//////                "checkSmsPermission" -> {
//////                    val smsSender = SmsSender(applicationContext)
//////                    result.success(smsSender.hasSmsPermission())
//////                }
//////                else -> {
//////                    result.notImplemented() // Handle methods not implemented
//////                }
//////            }
//////        }
//////    }
//////
//////    // This method handles the result of permission requests
//////    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//////        super.onRequestPermissionsResult(requestCode, permissions, grantResults) // Call super method
//////        if (requestCode == SEND_SMS_PERMISSION_REQUEST_CODE) {
//////            permissionResultCallback?.let { callback ->
//////                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//////                    // Permission granted
//////                    callback.success(true) // Indicate permission granted
//////                } else {
//////                    // Permission denied
//////                    callback.success(false) // Indicate permission denied
//////                }
//////                permissionResultCallback = null // Clear the callback after use
//////            }
//////        }
//////    }
//////}
////
////
////
//package com.example.ferrero_asset_management
//
//import android.Manifest // For Manifest.permission.SEND_SMS
//import android.content.Context // For applicationContext
//import android.content.pm.PackageManager // For PackageManager.PERMISSION_GRANTED
//import androidx.annotation.NonNull // For @NonNull annotation
//import androidx.core.app.ActivityCompat // For ActivityCompat.requestPermissions
//import io.flutter.embedding.android.FlutterActivity // Base class for Flutter activity
//import io.flutter.embedding.engine.FlutterEngine // For configuring Flutter engine
//import io.flutter.plugin.common.MethodChannel // For MethodChannel communication
//import android.net.Uri // <--- ADD THIS IMPORT for PathUtil
//// Make sure SmsSender.kt is in the same package path:
//// android/app/src/main/kotlin/com/example/ferrero_asset_management/SmsSender.kt
//import com.example.ferrero_asset_management.SmsSender
//// Make sure PathUtil.kt is in the same package path:
//// android/app/src/main/kotlin/com/example/ferrero_asset_management/PathUtil.kt
//import com.example.ferrero_asset_management.PathUtil // <--- ADD THIS IMPORT for PathUtil
//
//class MainActivity: FlutterActivity() {
//
//    // SMS Channel
//    private val SMS_CHANNEL = "com.ferrero.asset_management/sms" // Renamed for clarity
//    private val SEND_SMS_PERMISSION_REQUEST_CODE = 101
//    private var permissionResultCallback: MethodChannel.Result? = null // Nullable result callback
//
//    // PathUtil Channel
//    private val PATH_UTIL_CHANNEL = "com.ferrero_asset_management/path_util" // <--- PathUtil channel name
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine) // Call super method first
//
//        // --- SMS Method Channel Setup ---
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler {
//                call, result ->
//            when (call.method) {
//                "sendSms" -> {
//                    val phoneNumber = call.argument<String>("phoneNumber")
//                    val message = call.argument<String>("message")
//
//                    if (phoneNumber == null || message == null) {
//                        result.error("INVALID_ARGUMENTS", "Phone number or message cannot be null", null)
//                        return@setMethodCallHandler
//                    }
//
//                    val smsSender = SmsSender(applicationContext) // Use applicationContext
//
//                    if (smsSender.hasSmsPermission()) {
//                        val success = smsSender.sendSms(phoneNumber, message)
//                        result.success(success)
//                    } else {
//                        // Permission not granted, request it and store the result callback
//                        permissionResultCallback = result // Store the result callback
//                        ActivityCompat.requestPermissions(
//                            this, // Activity context
//                            arrayOf(Manifest.permission.SEND_SMS),
//                            SEND_SMS_PERMISSION_REQUEST_CODE
//                        )
//                    }
//                }
//                "checkSmsPermission" -> {
//                    val smsSender = SmsSender(applicationContext)
//                    result.success(smsSender.hasSmsPermission())
//                }
//                else -> {
//                    result.notImplemented() // Handle methods not implemented
//                }
//            }
//        }
//
//        // --- PathUtil Method Channel Setup --- <--- NEW SECTION
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PATH_UTIL_CHANNEL).setMethodCallHandler {
//                call, result ->
//            // This method is invoked on the main thread.
//            if (call.method == "getFilePathFromUri") {
//                val uriString = call.argument<String>("uriString")
//                if (uriString != null) {
//                    try {
//                        val uri = Uri.parse(uriString)
//                        val filePath = PathUtil.getPath(this.applicationContext, uri)
//                        if (filePath != null) {
//                            result.success(filePath)
//                        } else {
//                            result.error("PATH_NOT_FOUND", "Could not resolve file path for URI: $uriString", null)
//                        }
//                    } catch (e: Exception) {
//                        result.error("URI_PARSE_ERROR", "Error parsing URI or getting path: ${e.message}", e.toString())
//                    }
//                } else {
//                    result.error("INVALID_ARGUMENT", "uriString argument is null", null)
//                }
//            } else {
//                result.notImplemented() // Handle methods not implemented for this channel
//            }
//        }
//    }
//
//    // This method handles the result of permission requests
//    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//        super.onRequestPermissionsResult(requestCode, permissions, grantResults) // Call super method
//        if (requestCode == SEND_SMS_PERMISSION_REQUEST_CODE) {
//            permissionResultCallback?.let { callback ->
//                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                    // Permission granted
//                    callback.success(true) // Indicate permission granted
//                } else {
//                    // Permission denied
//                    callback.success(false) // Indicate permission denied
//                }
//                permissionResultCallback = null // Clear the callback after use
//            }
//        }
//        // No need to add PathUtil specific permission handling here,
//        // as PathUtil.getPath relies on ContentResolver which doesn't
//        // typically trigger onRequestPermissionsResult directly for content URIs.
//        // File pickers (like image_picker) handle their own permissions.
//    }
//}




package com.example.ferrero_asset_management

import android.Manifest // For Manifest.permission.SEND_SMS
import android.content.Context // For applicationContext
import android.content.pm.PackageManager // For PackageManager.PERMISSION_GRANTED
import androidx.annotation.NonNull // For @NonNull annotation
import androidx.core.app.ActivityCompat // For ActivityCompat.requestPermissions
import io.flutter.embedding.android.FlutterActivity // Base class for Flutter activity
import io.flutter.embedding.engine.FlutterEngine // For configuring Flutter engine
import io.flutter.plugin.common.MethodChannel // For MethodChannel communication
import android.util.Log // Import Log for authentication methods

// Make sure SmsSender.kt is in the same package path:
// android/app/src/main/kotlin/com/example/ferrero_asset_management/SmsSender.kt
import com.example.ferrero_asset_management.SmsSender

// Make sure AuthTokenManager.kt is in the same package path:
// android/app/src/main/kotlin/com/example/ferrero_asset_management/AuthTokenManager.kt
import com.example.ferrero_asset_management.AuthTokenManager // Import the AuthTokenManager


class MainActivity: FlutterActivity() {

    // Define channel names for different functionalities
    private val SMS_CHANNEL = "com.ferrero.asset_management/sms" // Existing SMS channel
    private val AUTH_CHANNEL = "com.example.ferrero_asset_management/auth" // NEW channel for authentication

    private val SEND_SMS_PERMISSION_REQUEST_CODE = 101

    private var permissionResultCallback: MethodChannel.Result? = null // Nullable result callback

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine) // Call super method first

        // --- SMS Channel Setup ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber == null || message == null) {
                        result.error("INVALID_ARGUMENTS", "Phone number or message cannot be null", null)
                        return@setMethodCallHandler
                    }

                    val smsSender = SmsSender(applicationContext) // Use applicationContext

                    if (smsSender.hasSmsPermission()) {
                        val success = smsSender.sendSms(phoneNumber, message)
                        result.success(success)
                    } else {
                        // Permission not granted, request it and store the result callback
                        permissionResultCallback = result // Store the result callback
                        ActivityCompat.requestPermissions(
                            this, // Activity context
                            arrayOf(Manifest.permission.SEND_SMS),
                            SEND_SMS_PERMISSION_REQUEST_CODE
                        )
                    }
                }
                "checkSmsPermission" -> {
                    val smsSender = SmsSender(applicationContext)
                    result.success(smsSender.hasSmsPermission())
                }
                else -> {
                    result.notImplemented() // Handle methods not implemented for this channel
                }
            }
        }

        // --- Authentication Channel Setup ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTH_CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "requestAuthToken" -> {
                    val username = call.argument<String>("username")
                    val password = call.argument<String>("password")

                    if (username == null || password == null) {
                        result.error("INVALID_ARGUMENTS", "Username and password cannot be null", null)
                        return@setMethodCallHandler
                    }

                    // Call your Kotlin AuthTokenManager
                    AuthTokenManager.requestAuthToken(username, password,
                        onSuccess = { authToken ->
                            // On success, send the token back to Flutter on the main thread
                            runOnUiThread { result.success(authToken) }
                        },
                        onError = { error ->
                            // On error, send the error message back to Flutter on the main thread
                            runOnUiThread {
                                Log.e("MainActivity", "Auth token request failed: ${error.message}", error)
                                result.error("AUTH_FAILED", error.message, null)
                            }
                        }
                    )
                }
                else -> {
                    result.notImplemented() // Handle methods not implemented for this channel
                }
            }
        }
    }

    // This method handles the result of permission requests (remains the same)
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults) // Call super method
        if (requestCode == SEND_SMS_PERMISSION_REQUEST_CODE) {
            permissionResultCallback?.let { callback ->
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Permission granted
                    callback.success(true) // Indicate permission granted
                } else {
                    // Permission denied
                    callback.success(false) // Indicate permission denied
                }
                permissionResultCallback = null // Clear the callback after use
            }
        }
    }
}
//package com.example.ferrero_asset_management
//
//import android.Manifest
//import android.content.Context
//import android.content.pm.PackageManager
//import androidx.annotation.NonNull
//import androidx.core.app.ActivityCompat
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import android.util.Log
//
//import com.example.ferrero_asset_management.SmsSender
//import com.example.ferrero_asset_management.AuthTokenManager
//// Import your PathUtil.kt if it's a class with methods
//// For 'object' style, it's directly accessible
//// REMOVED: import com.example.ferrero_asset_management.PathUtil // No longer needed if PathUtil channel is removed
//
//class MainActivity: FlutterActivity() {
//
//    private val SMS_CHANNEL = "com.ferrero.asset_management/sms"
//    private val AUTH_CHANNEL = "com.example.ferrero_asset_management/auth"
//    // REMOVED: PATH_UTIL_CHANNEL definition
//    // private val PATH_UTIL_CHANNEL = "com.ferrero.asset_management/path_util"
//
//    private val SEND_SMS_PERMISSION_REQUEST_CODE = 101
//
//    private var permissionResultCallback: MethodChannel.Result? = null
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        // --- SMS Channel Setup (existing) ---
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler {
//                call, result ->
//            when (call.method) {
//                "sendSms" -> {
//                    val phoneNumber = call.argument<String>("phoneNumber")
//                    val message = call.argument<String>("message")
//
//                    if (phoneNumber == null || message == null) {
//                        result.error("INVALID_ARGUMENTS", "Phone number or message cannot be null", null)
//                        return@setMethodCallHandler
//                    }
//
//                    val smsSender = SmsSender(applicationContext)
//
//                    if (smsSender.hasSmsPermission()) {
//                        val success = smsSender.sendSms(phoneNumber, message)
//                        result.success(success)
//                    } else {
//                        permissionResultCallback = result
//                        ActivityCompat.requestPermissions(
//                            this,
//                            arrayOf(Manifest.permission.SEND_SMS),
//                            SEND_SMS_PERMISSION_REQUEST_CODE
//                        )
//                    }
//                }
//                "checkSmsPermission" -> {
//                    val smsSender = SmsSender(applicationContext)
//                    result.success(smsSender.hasSmsPermission())
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }
//
//        // --- Authentication Channel Setup (existing) ---
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTH_CHANNEL).setMethodCallHandler {
//                call, result ->
//            when (call.method) {
//                "requestAuthToken" -> {
//                    val username = call.argument<String>("username")
//                    val password = call.argument<String>("password")
//
//                    if (username == null || password == null) {
//                        result.error("INVALID_ARGUMENTS", "Username and password cannot be null", null)
//                        return@setMethodCallHandler
//                    }
//
//                    AuthTokenManager.requestAuthToken(username, password,
//                        onSuccess = { authToken ->
//                            runOnUiThread { result.success(authToken) }
//                        },
//                        onError = { error ->
//                            runOnUiThread {
//                                Log.e("MainActivity", "Auth token request failed: ${error.message}", error)
//                                result.error("AUTH_FAILED", error.message, null)
//                            }
//                        }
//                    )
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }
//
//        // --- REMOVED: PATH UTILITY CHANNEL SETUP ---
//        // The following block has been removed as PathUtil is no longer needed
//        /*
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PATH_UTIL_CHANNEL).setMethodCallHandler {
//                call, result ->
//            when (call.method) {
//                "getPath", "getFilePathFromUri" -> {
//                    val uriString = call.argument<String>("uri")
//                    if (uriString == null) {
//                        result.error("INVALID_ARGUMENTS", "URI string cannot be null", null)
//                        return@setMethodCallHandler
//                    }
//                    try {
//                        val filePath = PathUtil.getPath(applicationContext, uriString)
//                        result.success(filePath)
//                    } catch (e: Exception) {
//                        Log.e("MainActivity", "Error in PathUtil method '${call.method}': ${e.message}", e)
//                        result.error("PATH_ERROR", e.message, null)
//                    }
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }
//        */
//    }
//
//    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//        if (requestCode == SEND_SMS_PERMISSION_REQUEST_CODE) {
//            permissionResultCallback?.let { callback ->
//                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                    callback.success(true)
//                } else {
//                    callback.success(false)
//                }
//                permissionResultCallback = null
//            }
//        }
//    }
//}
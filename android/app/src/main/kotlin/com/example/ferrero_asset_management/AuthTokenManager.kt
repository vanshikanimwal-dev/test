package com.example.ferrero_asset_management

//class AuthTokenManager {
//}
//package com.example.mytestapp // Adjust package as needed

import android.os.Handler
import android.os.Looper
import android.util.Log
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okhttp3.ResponseBody
import okhttp3.logging.HttpLoggingInterceptor
import okhttp3.MediaType.Companion.toMediaType
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException

// Use 'object' to create a singleton, providing easy access to methods without instance creation.
object AuthTokenManager {

    private const val TAG = "AuthTokenManager"
    private const val BASE_URL = "https://sarsatiya.store/XJAAM-0.0.1-SNAPSHOT"
    private const val TOKEN_URL = "$BASE_URL/token/generate-token" // Kotlin string interpolation
//    val JSON: MediaType = MediaType.get("application/json; charset=utf-8")
    val JSON: MediaType = "application/json; charset=utf-8".toMediaType()

    // OkHttpClient instance for networking, initialized once when the object is first accessed.
    private val okHttpClient: OkHttpClient

    // Handler to post results back to the main (UI) thread.
    private val mainThreadHandler = Handler(Looper.getMainLooper())

    // Static initializer block equivalent in Kotlin (called once when the object is accessed).
    init {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        okHttpClient = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .build()
    }

    /**
     * Requests an authentication token from the server asynchronously.
     * The result (token or error) is delivered via provided lambda callbacks,
     * which are posted to the main thread.
     *
     * @param username The username for authentication.
     * @param password The password for authentication.
     * @param onSuccess Callback function invoked on successful token retrieval,
     * receiving the token as a String.
     * @param onError Callback function invoked on failure, receiving a Throwable.
     */
    fun requestAuthToken(
        username: String,
        password: String,
        onSuccess: (String) -> Unit, // Kotlin lambda for success callback
        onError: (Throwable) -> Unit  // Kotlin lambda for error callback
    ) {
        val jsonBody = JSONObject().apply {
            try {
                put("username", username)
                put("password", password)
            } catch (e: JSONException) {
                Log.e(TAG, "Failed to create JSON for token request", e)
                mainThreadHandler.post { onError.invoke(e) } // Use invoke for clarity with lambdas
                return
            }
        }

        val requestBody = RequestBody.create(JSON, jsonBody.toString()) // Kotlin: MediaType first
        val request = Request.Builder()
            .url(TOKEN_URL)
            .post(requestBody)
            .build()

        Log.d(TAG, "Requesting auth token from: $TOKEN_URL")

        okHttpClient.newCall(request).enqueue(object : Callback { // Anonymous object for Callback
            override fun onFailure(call: Call, e: IOException) {
                Log.e(TAG, "Token request failed: Network error", e)
                mainThreadHandler.post { onError.invoke(e) }
            }

            override fun onResponse(call: Call, response: Response) {
                var responseBodyString = ""
                response.body?.use { responseBody -> // 'use' automatically closes the body
                    responseBodyString = responseBody.string()
                }

                if (!response.isSuccessful) {
                    Log.e(TAG, "Token request unsuccessful. Code: ${response.code}, Message: ${response.message}, Body: $responseBodyString")
                    mainThreadHandler.post {
                        onError.invoke(
                            IOException("Token request failed: ${response.code} ${response.message} - $responseBodyString")
                        )
                    }
                    return
                }

                Log.d(TAG, "Token response successful: $responseBodyString")

                try {
                    val tokenResponseJson = JSONObject(responseBodyString)
                    val authToken: String? = when { // Kotlin's 'when' expression
                        tokenResponseJson.has("token") -> tokenResponseJson.getString("token")
                        tokenResponseJson.has("id_token") -> tokenResponseJson.getString("id_token")
                        else -> null
                    }

                    if (authToken != null) {
                        Log.i(TAG, "Auth token obtained: ${authToken.take(20)}...") // Kotlin: take() for substring
                        mainThreadHandler.post { onSuccess.invoke(authToken) }
                    } else {
                        Log.w(TAG, "Token field ('token' or 'id_token') not found in JSON response. Check server. Response: $responseBodyString")
                        mainThreadHandler.post { onError.invoke(JSONException("Token field not found in response.")) }
                    }

                } catch (e: JSONException) {
                    Log.e(TAG, "Failed to parse token JSON response", e)
                    mainThreadHandler.post { onError.invoke(e) }
                }
            }
        })
    }
}
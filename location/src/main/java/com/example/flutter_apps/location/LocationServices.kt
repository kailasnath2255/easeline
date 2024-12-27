package com.example.flutter_apps.location

import android.content.Context
import android.location.Location
import android.os.Looper
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices

class LocationService(private val context: Context) {

    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null

    init {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: com.google.android.gms.location.LocationResult?) {
                locationResult?.let {
                    for (location in it.locations) {
                        // Process the location data here
                        println("Location changed: ${location.latitude}, ${location.longitude}")
                    }
                }
            }
        }
    }

    // Start location updates
    fun startLocationUpdates() {
        // Check for location permissions
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED &&
            ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted, handle accordingly (request permission)
            println("Permission not granted for location updates.")
            return
        }

        val locationRequest = LocationRequest.create().apply {
            interval = 1000L  // Update interval in milliseconds
            fastestInterval = 500L  // Fastest update interval
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        // Request location updates
        try {
            fusedLocationClient?.requestLocationUpdates(
                locationRequest,
                locationCallback!!,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            // Handle security exceptions for permission errors
            e.printStackTrace()
        }
    }

    // Stop location updates
    fun stopLocationUpdates() {
        fusedLocationClient?.removeLocationUpdates(locationCallback!!)
    }
}

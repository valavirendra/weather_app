## Android Permissions

Add these to android/app/src/main/AndroidManifest.xml
inside the <manifest> tag (before <application>):

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

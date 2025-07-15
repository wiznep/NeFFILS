-keep class com.google.crypto.tink.** { *; }
-keep class com.google.errorprone.annotations.**
-keep class javax.annotation.**
-keep class org.conscrypt.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**


# Keep Google Tink classes
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep Google HTTP Client
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# Keep Joda Time
-keep class org.joda.time.** { *; }
-dontwarn org.joda.time.**

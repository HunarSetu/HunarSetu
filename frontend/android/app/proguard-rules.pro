# Room resolves its generated implementation classes by name at runtime, so R8
# must not rename or remove them. Without this, androidx.work's startup
# ContentProvider dies with:
#   Failed to create an instance of class androidx.work.impl.WorkDatabase
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.room.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.startup.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-dontwarn androidx.work.**

# Flutter plugin entry points reached reflectively.
-keep class io.flutter.** { *; }
-keep class dev.fluttercommunity.** { *; }
-dontwarn io.flutter.embedding.**

# Native SQLite used by drift.
-keep class com.tekartik.sqflite.** { *; }
-keep class org.sqlite.** { *; }

package cc.zsakvo.otp

import io.flutter.embedding.android.FlutterFragmentActivity

//class MainActivity: FlutterFragmentActivity() {
//}


import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileDescriptor
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "package/Main"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val handlers = mapOf(
                "getSavedRoot" to ::getSavedRoot,         // root getSavedRoot()
                "selectDirectory" to ::selectDirectory,   // root selectDirectory()
                "releaseDirectory" to ::releaseDirectory, // void releaseDirectory(root)
                "createDirectory" to ::createDirectory,   // root createDirectory(root, name, overwrite)
                "writeFile" to ::writeFile                // void writeFile(root, name, type, overwrite, bytes)
            )
            if (call.method in handlers) {
                handlers[call.method]!!.invoke(call, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getSavedRoot(call: MethodCall, result: MethodChannel.Result) {
        val persistedPermissions = contentResolver.persistedUriPermissions
        for (p in persistedPermissions) {
            if (p.isWritePermission) {
                // we assume it's a document tree as we don't request anything else
                result.success(p.uri.toString())
                return
            }
        }
        result.error("no persist document tree", null, null)
    }

    private fun selectDirectory(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (pendingResult != null) {
                result.error("pending", "Already there's a pending request", null)
                return
            }
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            startActivityForResult(intent, 100)
            pendingResult = result
        } catch (e: Throwable) {
            Log.e("selectDirectory", "Unhandled error", e)
            result.error(e.javaClass.name, e.message, null)
        }
    }

    private fun releaseDirectory(call: MethodCall, result: MethodChannel.Result) {
        try {
            val rootUri = Uri.parse(call.argument<String>("root")!!)
            contentResolver.releasePersistableUriPermission(rootUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        } catch (e: Throwable) {
            Log.e("MainActivity::releaseDirectory", "Unhandled error", e)
            result.error(e.javaClass.name, e.message, null)
        }
    }

    private fun createDirectory(call: MethodCall, result: MethodChannel.Result) {
        try {
            // get root directory
            val rootUri = Uri.parse(call.argument<String>("root")!!)
            val root = DocumentFile.fromTreeUri(context, rootUri)
            if (root == null || !root.canWrite()) {
                result.error("access error", "Directory doesn't exist or it's not writable", null)
                return
            }

            // get arguments
            val name = call.argument<String>("name")!!
            val overwrite = call.argument<Boolean>("overwrite")

            // create directory, or just return found directory if overwrite==true
            val foundFile = root.findFile(name)
            if (foundFile != null && overwrite == null) {
                result.error("exists", "$name already exists", null)
                return
            }
            val file = if (foundFile != null && overwrite == true) foundFile else root.createDirectory(name)
            if (file == null) {
                result.error("creation failed", "Can't create directory $name", null)
                return
            }

            // return directory uri
            result.success(file.uri.toString())
        } catch (e: Throwable) {
            Log.e("MainActivity::createDirectory", "Unhandled error", e)
            result.error(e.javaClass.name, e.message, null)
        }
    }

    private fun writeFile(call: MethodCall, result: MethodChannel.Result) {
        try {
            // get root directory
            val rootUri = Uri.parse(call.argument<String>("root")!!)
            val root = DocumentFile.fromTreeUri(context, rootUri)
            if (root == null || !root.canWrite()) {
                result.error("access error", "Directory doesn't exist or it's not writable", null)
                return
            }

            // get arguments
            val fileName = call.argument<String>("name")!!
            val bytes = call.argument<ByteArray>("bytes")!!
            val fileType = call.argument<String>("type") ?: "*/*"
            val overwrite = call.argument<Boolean>("overwrite")

            // get subdirectory
            val dirName = call.argument<String>("subdir")!!
            val dir = root.findFile(dirName)
            if (dir == null || !dir.isDirectory()) {
                result.error("invalid_subdir", "$dirName is not a valid subdirectory", null)
                return
            }

            // create new file, or just return found file if overwrite==true
            val foundFile = dir.findFile(fileName)
            if (foundFile != null && overwrite == null) {
                result.error("exists", "$fileName already exists", null)
                return
            }
            val file = if (foundFile != null && overwrite == true) foundFile else dir.createFile(fileType, fileName)
            if (file == null) {
                result.error("creation failed", "Can't create file $fileName", null)
                return
            }

            // write bytes to file
            contentResolver.openFileDescriptor(file.uri, "w").use { fd ->
                FileOutputStream(fd!!.fileDescriptor).use { os ->
                    os.write(bytes)
                    os.flush()
                }
            }

            result.success(null)
        } catch (e: Throwable) {
            Log.e("MainActivity::writeFile", "Unhandled error", e)
            result.error(e.javaClass.name, e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (pendingResult == null || requestCode != 100) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult!!
        pendingResult = null
        try {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri = data.data!!
                contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                result.success(uri.toString())
            } else {
                result.error("canceled", null, null)
            }
            return
        } catch (e: Throwable) {
            result.error(e.javaClass.name, e.message, null)
        }
    }
}


$out = new-object byte[] 1048576000; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes($("F:\Syncfolder\$([System.IO.Path]::GetRandomFileName())"), $out)

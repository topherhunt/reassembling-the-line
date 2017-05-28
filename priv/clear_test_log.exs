System.cmd("mkdir", ["-p", "log"])
System.cmd("cp", ["/dev/null", "log/test.log"])
System.cmd("touch", ["log/test.log"])

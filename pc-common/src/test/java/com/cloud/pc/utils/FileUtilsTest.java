package com.cloud.pc.utils;

import org.junit.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;

import static org.junit.Assert.*;

public class FileUtilsTest {
    @Test
    public void Test_mkParentDir() throws IOException {
        Path root = Files.createTempDirectory("pcache-parent-dir");
        try {
            Path file = root.resolve("test_dir_sub").resolve("1");
            boolean ret = FileUtils.mkParentDir(file);
            assertTrue(ret);
            ret = FileUtils.mkParentDir(file);
            assertTrue(ret);
            assertTrue(Files.isDirectory(root.resolve("test_dir_sub")));
        } finally {
            Files.walk(root)
                    .sorted(Comparator.reverseOrder())
                    .forEach(path -> path.toFile().delete());
        }

        assertFalse(FileUtils.mkParentDir(null));
    }
}

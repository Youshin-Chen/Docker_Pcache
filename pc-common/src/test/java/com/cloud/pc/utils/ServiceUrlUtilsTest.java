package com.cloud.pc.utils;

import org.junit.Assert;
import org.junit.Test;

public class ServiceUrlUtilsTest {

    @Test
    public void shouldUsePublicUrlOverride() throws Exception {
        String serviceUrl = ServiceUrlUtils.getServiceUrl("host.docker.internal:8080",
                "http://", "", 9000);
        Assert.assertEquals("http://host.docker.internal:8080/", serviceUrl);
    }

    @Test
    public void shouldKeepSchemeAndAppendSlash() {
        String serviceUrl = ServiceUrlUtils.normalizeUrl("https://demo.local:9443", "http://");
        Assert.assertEquals("https://demo.local:9443/", serviceUrl);
    }
}

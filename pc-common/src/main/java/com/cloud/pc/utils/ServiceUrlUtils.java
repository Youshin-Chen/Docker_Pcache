/*
 * Copyright (c) 2025 Yangagile. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.cloud.pc.utils;

import org.apache.commons.lang3.StringUtils;

import java.net.SocketException;

public class ServiceUrlUtils {

    public static String getServiceUrl(String publicUrl, String httpHeader,
                                       String interfaceName, int port) throws SocketException {
        if (StringUtils.isNotBlank(publicUrl)) {
            return normalizeUrl(publicUrl, httpHeader);
        }
        String url = StringUtils.defaultIfBlank(httpHeader, "http://")
                + NetworkUtils.getLocalIpAddress(interfaceName) + ":" + port;
        return normalizeUrl(url, httpHeader);
    }

    public static String normalizeUrl(String url, String httpHeader) {
        String normalized = StringUtils.trimToEmpty(url);
        if (StringUtils.isBlank(normalized)) {
            return StringUtils.defaultIfBlank(httpHeader, "http://");
        }
        if (!normalized.contains("://")) {
            normalized = StringUtils.defaultIfBlank(httpHeader, "http://") + normalized;
        }
        if (!normalized.endsWith("/")) {
            normalized = normalized + "/";
        }
        return normalized;
    }
}

/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hive.jdbc;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

@RunWith(JUnit4.class)
public class TestUtils {

  @Test
  public void testSanitizeAuthUserNull() {
    assertNull("Null input should return null", Utils.sanitizeAuthUser(null));
  }

  @Test
  public void testSanitizeAuthUserWithoutAt() {
    assertEquals("user.name should become user_name", 
        "user_name", Utils.sanitizeAuthUser("user.name"));
    assertEquals("user.name.test should become user_name_test", 
        "user_name_test", Utils.sanitizeAuthUser("user.name.test"));
    assertEquals("username without dots should remain unchanged", 
        "username", Utils.sanitizeAuthUser("username"));
    assertEquals("empty string should remain empty", 
        "", Utils.sanitizeAuthUser(""));
  }

  @Test
  public void testSanitizeAuthUserWithEmail() {
    assertEquals("user.name@domain.com should become user_name@domain.com", 
        "user_name@domain.com", Utils.sanitizeAuthUser("user.name@domain.com"));
    assertEquals("user.name.test@sub.domain.com should become user_name_test@sub.domain.com", 
        "user_name_test@sub.domain.com", Utils.sanitizeAuthUser("user.name.test@sub.domain.com"));
    assertEquals("username@domain.com should remain unchanged", 
        "username@domain.com", Utils.sanitizeAuthUser("username@domain.com"));
    assertEquals("user@domain.com should remain unchanged", 
        "user@domain.com", Utils.sanitizeAuthUser("user@domain.com"));
  }

  @Test
  public void testSanitizeAuthUserEdgeCases() {
    assertEquals("@domain.com should remain unchanged", 
        "@domain.com", Utils.sanitizeAuthUser("@domain.com"));
    assertEquals("user@ should remain unchanged", 
        "user@", Utils.sanitizeAuthUser("user@"));
    assertEquals("user.@domain.com should become user_@domain.com", 
        "user_@domain.com", Utils.sanitizeAuthUser("user.@domain.com"));
    assertEquals(".user@domain.com should become _user@domain.com", 
        "_user@domain.com", Utils.sanitizeAuthUser(".user@domain.com"));
    assertEquals("user.name.@domain.com should become user_name_@domain.com", 
        "user_name_@domain.com", Utils.sanitizeAuthUser("user.name.@domain.com"));
    assertEquals("multiple..dots@domain.com should become multiple__dots@domain.com", 
        "multiple__dots@domain.com", Utils.sanitizeAuthUser("multiple..dots@domain.com"));
  }

  @Test
  public void testSanitizeAuthUserMultipleAtSymbols() {
    assertEquals("user.name@domain@other.com should become user_name@domain@other.com", 
        "user_name@domain@other.com", Utils.sanitizeAuthUser("user.name@domain@other.com"));
    assertEquals("user@domain.com@extra should become user@domain.com@extra", 
        "user@domain.com@extra", Utils.sanitizeAuthUser("user@domain.com@extra"));
  }
}

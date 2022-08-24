// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {LibStringUtils} from "src/LibStringUtils.sol";

contract LibStringUtilsTest is Test {
    //You can also use the option bellow if you want to "string".method(x)
    //using LibStringUtils for string;
    function setUp() public {}

    function testAt() public {
        assertEq(LibStringUtils.at("milady", 1), "i");
    }

    function testAtLong() public {
        assertEq(
            LibStringUtils.at(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                40
            ),
            "d"
        );
    }

    function testFailAt() public {
        assertEq(LibStringUtils.at("milady", 10), "i");
    }

    function testCharAt() public {
        assertEq(LibStringUtils.charAt("milady", 1), "i");
    }

    function testCharAtLong() public {
        assertEq(
            LibStringUtils.at(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                40
            ),
            "d"
        );
    }

    function testCharCode() public {
        assertEq(LibStringUtils.charCodeAt("milady", 1), 105);
    }

    function testCharCodeLong() public {
        assertEq(
            LibStringUtils.charCodeAt(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                40
            ),
            100
        );
    }

    function testCharCodeFail() public {
        assertEq(LibStringUtils.charCodeAt("milady", 7), 0);
    }

    function testCodePointAt() public {
        assertEq(LibStringUtils.codePointAt("milady", 1), 105);
    }

    function testCodePointAtLong() public {
        assertEq(
            LibStringUtils.codePointAt(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                40
            ),
            100
        );
    }

    function testFailCodePointAt() public {
        assertEq(LibStringUtils.codePointAt("milady", 7), 0);
    }

    function testEndsWith() public {
        assertTrue(LibStringUtils.endsWith("milady", "dy"));
    }

    function testEndsWithLong() public {
        assertTrue(
            LibStringUtils.endsWith(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                "milady"
            )
        );
    }

    function testEndsWithSmall() public {
        assertTrue(LibStringUtils.endsWith("milady", "y"));
    }

    function testEndsWithFail() public {
        assertFalse(LibStringUtils.endsWith("milady", "la"));
    }

    function testStartWith() public {
        assertTrue(LibStringUtils.startsWith("milady", "mi", 0));
    }

    function testStartWithLong() public {
        assertTrue(
            LibStringUtils.startsWith(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                "milady",
                36
            )
        );
    }

    function testStartWithSmall() public {
        assertTrue(LibStringUtils.startsWith("milady", "y", 5));
    }

    function testStartsWithFail() public {
        assertFalse(LibStringUtils.startsWith("milady", "la", 1));
    }

    function testStartsWithSameSize() public {
        assertTrue(LibStringUtils.startsWith("milady", "milady", 0));
    }

    function testStartsWithLongerSizeFail() public {
        assertFalse(LibStringUtils.startsWith("milady", "miladyy", 0));
    }

    function testSubstring32() public {
        assertEq(
            LibStringUtils.substring32(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                0,
                32
            ),
            "miladymiladymiladymiladymiladymi"
        );
    }

    function testSubstring32Small() public {
        assertEq(
            LibStringUtils.substring32(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                30,
                36
            ),
            "milady"
        );
    }

    function testFailSubstring32() public {
        assertEq(
            LibStringUtils.substring32(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                0,
                33
            ),
            "miladymiladymiladymiladymiladymil"
        );
    }

    function testFailSubstring32TooLong() public pure {
        LibStringUtils.substring32(
            "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
            0,
            80
        );
    }

    function testSubstring() public {
        assertEq(
            LibStringUtils.substring(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                0,
                32
            ),
            "miladymiladymiladymiladymiladymi"
        );
    }

    function testSubstringLong() public {
        assertEq(
            LibStringUtils.substring(
                "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
                0,
                36
            ),
            "miladymiladymiladymiladymiladymilady"
        );
    }

    function testFailSubstringTooLong() public pure {
        LibStringUtils.substring(
            "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady",
            0,
            80
        );
    }

    function testIndexOf() public {
        assertEq(LibStringUtils.indexOf("milady", "mi"), 0);
    }

    function testIndexOfLong() public {
        assertEq(
            LibStringUtils.indexOf(
                "tobeornottobethatisthequestiontobeornottobethatisthequestion",
                "question"
            ),
            22
        );
    }

    function testIndexOfOver() public {
        assertEq(LibStringUtils.indexOf("milady", "miladyy"), 0);
    }

    function testMatch() public {
        assertTrue(LibStringUtils.matches("milady", "mi"));
    }

    function testMatchFail() public {
        assertFalse(LibStringUtils.matches("milady", "my"));
    }

    function testMatchLong() public {
        assertTrue(
            LibStringUtils.matches(
                "tobeornottobethatisthequestiontobeornottobethatisthequestion",
                "question"
            )
        );
    }

    function testTrimAllWhitespace() public {
        assertEq(
            LibStringUtils.trimAllWhitespaces(
                "      m      i        l     a    d     y  "
            ),
            "milady"
        );
    }

    function testTrimLeft() public {
        assertEq(LibStringUtils.trimLeft("      milady"), "milady");
    }

    function testTrimRigth() public {
        assertEq(LibStringUtils.trimRight("milady     "), "milady");
    }

    function testTrim() public {
        assertEq(LibStringUtils.trim("      mi lady  "), "mi lady");
    }

    function testToUpper() public {
        assertEq(LibStringUtils.toUpper("milady"), "MILADY");
    }

    function testToUpperLong() public {
        assertEq(
            LibStringUtils.toUpper("miladymiladymiladymiladymiladymilady"),
            "MILADYMILADYMILADYMILADYMILADYMILADY"
        );
    }

    function testToLower() public {
        assertEq(LibStringUtils.toLower("MILADY"), "milady");
    }

    function testToLowerLong() public {
        assertEq(
            LibStringUtils.toLower("MILADYMILADYMILADYMILADYMILADYMILADY"),
            "miladymiladymiladymiladymiladymilady"
        );
    }

    function testSplit32() public {
        string[] memory str = new string[](2);
        str[0] = "m";
        str[1] = "lady";

        string[] memory strSplit = LibStringUtils.split32("milady", "i");
        assertEq(str[0], strSplit[0]);
        assertEq(str[1], strSplit[1]);
        assertEq(str.length, strSplit.length);
    }

    function testSplit32Max() public {
        string[] memory str = new string[](6);
        str[0] = "mi";
        str[1] = "dymi";
        str[2] = "dymi";
        str[3] = "dymi";
        str[4] = "dymi";
        str[5] = "dy";

        string[] memory strSplit = LibStringUtils.split32(
            "miladymiladymiladymiladymilady",
            "la"
        );
        assertEq(str[0], strSplit[0]);
        assertEq(str[1], strSplit[1]);
        assertEq(str[2], strSplit[2]);
        assertEq(str[3], strSplit[3]);
        assertEq(str[4], strSplit[4]);
        assertEq(str[5], strSplit[5]);
        assertEq(str.length, strSplit.length);
    }

    //Out of gas error. Do not debug this with forge debug it will freeze
    function testFailSplit32() public {
        string[] memory str = new string[](8);
        str[0] = "m";
        str[1] = "ladym";
        str[2] = "ladym";
        str[3] = "ladym";
        str[4] = "ladym";
        str[5] = "ladym";
        str[6] = "ladym";
        str[7] = "lady";

        string[] memory strSplit = LibStringUtils.split32(
            "miladymiladymiladymiladymiladymiladymilady",
            "i"
        );
        assertEq(str[0], strSplit[0]);
        assertEq(str[1], strSplit[1]);
        assertEq(str[2], strSplit[2]);
        assertEq(str[3], strSplit[3]);
        assertEq(str[4], strSplit[4]);
        assertEq(str[5], strSplit[5]);
        assertEq(str[6], strSplit[6]);
        assertEq(str[7], strSplit[7]);
        assertEq(str.length, strSplit.length);
    }

    function testConcatenate() public {
        assertEq(LibStringUtils.concatenate("mi", "lady"), "milady");
    }

    function testConcatenateLong() public {
        assertEq(
            LibStringUtils.concatenate(
                "miladymiladymiladymiladymiladymiladymilady",
                "miladymiladymiladymiladymiladymiladymilady"
            ),
            "miladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymiladymilady"
        );
    }
}

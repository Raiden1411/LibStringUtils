// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

library LibStringUtils {

    error NotValidIndex();
    error NotValidLength();
    error HexLengthInsufficient();

    function at(string memory _str, uint value) internal pure returns(string memory result) {
        assembly{
            //Check if the value of the index provided is >= than the length on the string. Revert if the condition is true
            if or(gt(value, mload(_str)), eq(value, mload(_str))) {
                //Store the offset of NotValidIndex()
                mstore(0x00, 0x4d999543)
                //Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            //Loads the free memory pointer
            result := mload(0x40)
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(_str, add(0x20, value)) where value of index is zero. Then the string stored will be milady
            //add(_str, add(0x20, value)) where value of index is one. Then the string stored will be ilady and so on
            let partialString := add(_str, add(0x20, value))
            //Performs a mstore of 8bits. Right shift 248 or 0xf8 to grab the first char in the string loaded
            mstore8(add(result, 0x20), shr(248, mload(partialString)))
            //Stores the string length that will always be one.
            mstore(result, 1)
            //Stores the full string in the next available space
            //0x0 - length
            //0x20 - string value
            //0x40 - length + string value
            mstore(0x40, add(result, 0x40))
        }
    }

    function charAt(string memory _str, uint value) internal pure returns(string memory result) {
        assembly{
            //Loads the free memory pointer
            //This function does not revert like the at function making it more gas efficient because of the lack of the checks needed
            result := mload(0x40)
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(_str, add(0x20, value)) where value of index is zero. Then the string stored will be milady
            //add(_str, add(0x20, value)) where value of index is one. Then the string stored will be ilady and so on
            let partialString := add(_str, add(0x20, value))
            //Performs a mstore of 8bits. Right shift 248 or 0xf8 to grab the first char in the string loaded
            mstore8(add(result, 0x20), shr(248, mload(partialString)))
            //Stores the string length that will always be one.
            mstore(result, 1)
            //Stores the full string in the next available space
            //0x0 - length
            //0x20 - string value
            //0x40 - length + string value
            mstore(0x40, add(result, 0x40))
        }
    }

    function charCodeAt(string memory _str, uint value) internal pure returns(uint result) {
        assembly{
            //This function does not revert like the at function making it more gas efficient because of the lack of the checks needed
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(_str, add(0x20, value)) where value of index is zero. Then the string stored will be milady
            //add(_str, add(0x20, value)) where value of index is one. Then the string stored will be ilady and so on
            let partialString := add(_str, add(0x20, value))
            //Performs a mstore of 8bits. Right shift 248 or 0xf8 to grab the first char in the string loaded
            result := shr(248, mload(partialString))
        }
    }

    function codePointAt(string memory _str, uint value) internal pure returns(uint result) {
        assembly{
            //Check if the value of the index provided is >= than the length on the string. Revert if the condition is true
            if or(gt(value, mload(_str)), eq(value, mload(_str))) {
                //Store the offset of NotValidIndex()
                mstore(0x00, 0x4d999543)
                //Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(_str, add(0x20, value)) where value of index is zero. Then the string stored will be milady
            //add(_str, add(0x20, value)) where value of index is one. Then the string stored will be ilady and so on
            let partialString := add(_str, add(0x20, value))
            //Performs a mstore of 8bits. Right shift 248 or 0xf8 to grab the first char in the string loaded
            result := shr(248, mload(partialString))
        }
    }

    function endsWith(string memory compare, string memory compareTo) internal pure returns(bool checked) {
        assembly{
            let compareToLength := mload(compareTo)
            let compareLength := mload(compare)
            checked := false
            //Check if the compareTo length is > than the length of the compare string. Returns false if the condition is true
            if gt(compareToLength, compareLength) {
                //Stores 0 to return false
                checked := false
                //Revert with (offset, size).
            }

            if eq(compareLength, compareToLength) {
                checked := true
            }
            //Substracts the leght of the string we want to compare with the length of the string to match with
            let length := sub(compareLength, compareToLength)
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(compareTo, 0x20) get the value "milady" from memory 
            let partialStringToCompare := add(compareTo, 0x20)
            //Loads memory from 0 to calculated length cut out.
            //Example:
            //milady = 6 length. y = 1 length. 6-1 = 5
            //add(compare, add(0x20,5))
            //the result value would have the first 5 letters cut off in this step
            let partialString := add(compare, add(0x20, length))

            //compares the loaded values and if they are eq returns true
            if eq(mload(partialString), mload(partialStringToCompare)) {
                checked := true
            }
        }
    }

    function startsWith(string memory compare, string memory compareTo, uint position) internal pure returns(bool checked) {
        assembly{
            let compareToLength := mload(compareTo)
            let compareLength := mload(compare)
            checked := false
            //Check if the compareTo length is > than the length of the compare string. Returns false if the condition is true
            if gt(compareToLength, compareLength) {
                checked := false
            }

            if eq(compareLength, compareToLength) {
                checked := true
            }
            //Calcutes bits used for shifting right based on the compareToLength
            let pattern := shl(3, sub(32, and(compareToLength, 31)))
            //Shifts by pattern calculated above on the string values
            let partialStringToCompare := shr(pattern, mload(add(compareTo, 0x20)))
            let partialString := shr(pattern, mload(add(compare, add(0x20, position))))
            //compares the loaded values and if they are eq returns true
            if eq(partialString, partialStringToCompare) {
                checked := true
            }
        }
    }

    function substring32(string memory str, uint startPos, uint endPos) internal pure returns(string memory result) {
        assembly {
            //This only works on 32 bit buffers. Use it if you want to substring on a string and that size is less than 32 bits long. Its more gas efficient
            if gt(endPos, mload(str)){
                //Store the offset of NotValidLength()
                mstore(0x00, 0x0d74140c)
                //Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            result := mload(0x40)
            //Stores in memory the string at the index of value
            //Example string: milady
            //add(_str, add(0x20, value)) where value of index is zero. Then the string stored will be milady
            //add(_str, add(0x20, value)) where value of index is one. Then the string stored will be ilady and so on
            let startString := add(str, add(0x20, startPos))
            //Store the first 32 bits
            mstore(add(result, 0x20), mload(startString))
            //Stores 0s at result ptr + 0x20 + endPos or in other words after the last char
            mstore(add(result, add(0x20, endPos)), 0)
            //Stores the string length that will always be one.
            mstore(result, sub(endPos, startPos))
            //Stores the full string in the next available space
            //0x0 - length
            //0x20 - string value
            //0x40 - length + string value
            mstore(0x40, add(result, 0x40))
        }
    }

    function substring(string memory str, uint startPos, uint endPos) internal pure returns(string memory result) {
        //This is less gas efficient but its not limited to just a 32bit buffer
        assembly {
            if gt(endPos, mload(str)) {
                //Store the offset of NotValidLength()
                mstore(0x00, 0x0d74140c)
                //Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            //Loads free memory pointer
            result := mload(0x40)
            //Calculates the length of the new string
            let length := sub(endPos, startPos)
            //Starts a counter to use it to calculate the memory position to store the individual chars
            let counter := 0
            //Loops one word at a time
            for {let i:= startPos} lt(i, endPos) {i:= add(i, 0x20)}{
                //Sets up memory position to load it from memory
                let startString := add(str, add(0x20, i))
                //Store the first 32 bits
                mstore(add(result, add(0x20, mul(0x20, counter))), mload(startString))
                //Updates counter
                counter := add(counter, 1)
            }
            //Stores the length
            mstore(result, length)
            //Adds enough memory room to return the calculated string based on the length of the string provided in the method.
            //This way it always has enough room to return the full string.
            mstore(0x40, add(result, and(add(mload(str), 0x40), not(0x1f))))
        }
    }

    function indexOf(string memory str, string memory char) internal pure returns(uint result) {
        assembly {
            //Adds 32bits to memory position to get access to the string value
            let length := mload(str)
            let pattern := shl(3, sub(32, and(mload(char), 31)))
            char := add(char, 0x20)

            let index := 0
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //Sets up memory position to load it from memory
                let startString := add(str, add(0x20, i))
                //Creates a new string of just one char long and use it to compare to the string provided
                //let compareString := shl(0xF8, shr(0xF8, mload(startString)))
                //Compares and if true return the value of i from the loop and halts execution
                //if eq(compareString, mload(char))
                if iszero(shr(pattern, xor(mload(char), mload(startString))))
                {
                    //Store index value and breaks
                    index := i
                    break
                }
            }

            //Return 0 if nothing applies or if index 0
            result := index
        }
    }

    function matches(string memory subject, string memory search) internal pure returns(bool pat){
        assembly{
            let length := mload(subject)
            //Calculate value to be use on shift right.
            //Example 32 - (3 & 31) << 3 = 232
            let pattern := shl(3, sub(32, and(mload(search), 31)))
            search := add(search, 0x20)
            pat := false
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //Sets up memory position to load it from memory
                let startString := add(subject, add(0x20, i))
                //Creates a new string of just one char long and use it to compare to the string provided
                //Compares by xoring and then shifting to calculated amount. If true returns true and halts execution
                //0x6d696c6164790000000000000000000000000000000000000000000000000000
                //0x6d00000000000000000000000000000000000000000000000000000000000000
                //XOR = 0x00696c6164790000000000000000000000000000000000000000000000000000 
                //PATTERN = 248
                //RESULT -> 0x00696c6164790000000000000000000000000000000000000000000000000000 << 248 = 00
                if iszero(shr(pattern, xor(mload(search), mload(startString)))){
                    pat := true
                    break
                }
            }
        }
    }

    function trimAllWhitespaces(string memory str) internal pure returns(string memory result) {
        assembly {
            //Adds 32bits to memory position to get access to the string value
            result := mload(0x40)
            let counter := 0
            let whitespace := shl(0xF8, 0x20)
            for {let i:= 0} lt(i, mload(str)) {i:= add(i, 1)}{
                //Sets up memory position to load it from memory
                let startString := add(str, add(0x20, i))
                let shiftedString := shl(0xF8, shr(0xF8, mload(startString)))
                if eq(shiftedString, whitespace){
                    continue
                }
                //Store the char at the calculated memory postion. Uses a shr of 248 to grab the first char each time.
                mstore8(add(result, add(0x20, counter)), shr(0xF8, mload(startString)))
                //Updates counter
                counter := add(counter, 1)
                
            }

            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(result, counter)
            mstore(0x40, add(result, and(add(mload(str), 0x40), not(0x1f))))
        }
    }

    function trimLeft(string memory str) internal pure returns(string memory result) {
        assembly {
            //Adds 32bits to memory position to get access to the string value
            result := mload(0x40)
            let length := mload(str)
            //Move pointer to start of the string
            str := add(str, 0x20)
            //Start length counter
            let counter := 0
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //Sets up memory position to load it from memory
                let trimstr := add(str, i)
                //Reduce it to one bit for compare for whitespace
                let shiftedString := shr(0xF8, mload(trimstr))
                if eq(shiftedString, 0x20){
                    //add to length and continue
                    counter := add(counter, 1)
                    continue
                }
                //Breaks if the condition above is not true
                break
                
            }

            //Stores the calculated length for the new string
            mstore(result, sub(length, counter))
            //Stores its value
            mstore(add(result, 0x20), mload(add(str, counter)))
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(length, 0x40), not(0x1f))))
        }
    }

    function trimRight(string memory str) internal pure returns(string memory result) {
        assembly {
            //Adds 32bits to memory position to get access to the string value
            result := mload(0x40)
            let length := mload(str)
            //Move pointer to start of the string
            let strEnd := add(str, add(0x20, sub(length, 1)))
            //Start length counter
            let counter := 0
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //Sets up memory position to load it from memory
                let trimstr := sub(strEnd, i)
                //Reduce it to one bit for compare for whitespace
                let shiftedString := shr(0xF8, mload(trimstr))
                if eq(shiftedString, 0x20){
                    //add to length and continue
                    counter := add(counter, 1)
                    continue
                }
                //Breaks if the condition above is not true
                break
                
            }

            let calculatedLength := sub(length, counter)
            //Stores the calculated length for the new string
            mstore(result, calculatedLength)
            //Stores its value
            //shr(sub(256, mul(8, lengthmload(add(str, calculatedLength))
            let pattern := shl(3, sub(32, and(calculatedLength, 31)))
            mstore(add(result, 0x20), shl(pattern, shr(pattern, mload(add(str, 0x20)))))
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(length, 0x40), not(0x1f))))
        }
    }

    function trim(string memory str) internal pure returns(string memory result) {
        result = trimLeft(str);
        result = trimRight(result);
    }

    function toUpper(string memory str) internal pure returns(string memory result) {
        assembly{
            //loads free memory pointer
            result := mload(0x40)
            //get string length
            let length := mload(str)
            //stores length of resulting string
            mstore(result, length)
            //move pointer to start of the string
            str := add(str, 0x20)
            //move pointer to start of resulting string
            result := add(mload(0x40), 0x20)
            //start loop
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //load values one by one from left to right
                let partialStr := add(str, i)
                //grabs first char
                let char := shr(0xF8, mload(partialStr))
                //branchless way to check char >= 'a' && char <= 'z'
                let check := mul(0x20, and(or(gt(char, 0x61), eq(0x61, char)), or(gt(0x7a, char), eq(0x7a, char))))
                //stores char one by one at the pointer + i
                mstore8(add(result, i), sub(char, check))
            }
            // Move the pointer and allocate memory
            result := sub(result, 0x20)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(length, 0x40), not(0x1f))))
        }
    }

    function toLower(string memory str) internal pure returns(string memory result) {
        assembly{
            //loads free memory pointer
            result := mload(0x40)
            //get string length
            let length := mload(str)
            //stores length of resulting string
            mstore(result, length)
            //move pointer to start of the string
            str := add(str, 0x20)
            //move pointer to start of resulting string
            result := add(mload(0x40), 0x20)
            //start loop
            for {let i:= 0} lt(i, length) {i:= add(i, 1)}{
                //load values one by one from left to right
                let partialStr := add(str, i)
                //grabs first char
                let char := shr(248, mload(partialStr))
                //branchless way to check char >= 'A' && char <= 'Z'
                let check := mul(32, and(or(gt(char, 0x41), eq(0x41, char)), or(gt(0x5a, char), eq(0x5a, char))))
                //stores char one by one at the pointer + i
                mstore8(add(result, i), add(char, check))
            }
            // Move the pointer and allocate memory
            result := sub(result, 0x20)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32
            mstore(0x40, add(result, and(add(length, 0x40), not(0x1f))))
        }
    }

    //This function is cheaper than string.concat()
    function concatenate(string memory subject, string memory concat) internal pure returns(string memory result){
        assembly{
            //Load length
            let subjectLength := mload(subject)
            let concatenateLength := mload(concat)
            //Load Free memory pointer
            result := mload(0x40)
            //Calculates the result length
            let totalLength := add(subjectLength, concatenateLength)
            //Moves pointer
            subject := add(subject, 0x20)
            concat := add(concat, 0x20)
            //Stores result length
            mstore(result, totalLength)
            //Loops one word at a time
            for { let w := 0 } 1 {} {
                //Stores 32 bytes
                mstore(add(result, add(w, 0x20)), mload(add(subject, w)))
                w := add(w, 0x20)
                if iszero(lt(w, subjectLength)) { break }
            }
            //Loops one word at a time
            for { let o := 0 } 1 {} {
                //Stores 32 bytes at the result pointer + subjectLength
                mstore(add(result, add(0x20, add(o, subjectLength))), mload(add(concat, o)))
                o := add(o, 0x20)
                // prettier-ignore
                if iszero(lt(add(o, subjectLength), totalLength)) { break }
            }
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(totalLength, 0x40), not(0x1f))))
        }
    }

    function concatenate32(string memory subject, string memory concat) internal pure returns(string memory result){
        assembly{
            //Loads strings length
            let subjectLength := mload(subject)
            let concatLength := mload(concat)
            //Load free memory pointer
            result := mload(0x40)
            //Calculate total length
            let length := add(subjectLength, concatLength)
            //Moves pointer by 0x20
            subject := add(subject, 0x20)
            concat := add(concat, 0x20)
            //Store string length
            mstore(result, length)
            //Stores the subject at the begining of the pointer
            mstore(add(result, 0x20), mload(subject))
            //Moves pointer by subjectLength and stores the delimiter there
            mstore(add(result, add(0x20, subjectLength)), mload(concat))
            //Allocate memory for the length and the bytes,
            //rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(length, 0x40), not(0x1f))))
        }
    }

    // Great learning experience and by far the most challenging one here
    function split(string memory subject, string memory delim) internal pure returns(string[] memory result){
        string memory val = concatenate(subject, delim);
        assembly {
            let delimLength := mload(delim)
            let length := mload(val)
            //Create new pointer for substrings
            let ptr := add(mload(0x40), 0x20)
            //copies pointer to the stack so it can be used to calculate the pointer location of the strings
            let copyPtr := ptr
            //Sets helper counter used to calculate string length and array length
            //Counter for array length
            let counter := 0
            //Counter for string length
            let lengthCounter := 0
            //Counter for total substrings length
            let arrMemoryAlloc := 0
            //Grabs hex value of the delimiter
            let pattern := shl(3, sub(32, and(delimLength, 31)))
            //Moves pointer to start of the string value
            val := add(val, 0x20)
            delim := add(delim, 0x20)
            let hash := 0
            if gt(delimLength, 32){
                hash := keccak256(delim, delimLength)
            }
            //Loops one char at a time
            for {let i:= 0} or(eq(i, length), lt(i, length)) {}{
                //Moves pointer by i value
                let start := add(val, i)
                //If the hash is not 0 then we perform the string calcs from here
                if hash {
                    if iszero(eq(keccak256(start, delimLength), hash)){
                        mstore(add(ptr, add(0x20, lengthCounter)), mload(start))
                        //Adds one to word length
                        lengthCounter := add(lengthCounter, 1)
                        //Skips to next char
                        i:= add(i, 1)
                        continue
                    }

                    if eq(keccak256(start, delimLength), hash){
                        if iszero(eq(lengthCounter, 0)){
                            //Stores 0s based on the pointer location with the length counter added so we can clean the bits that we don't care about
                            mstore(add(ptr, add(0x20, lengthCounter)), 0)
                            //Stores length at the ptr current location
                            mstore(ptr, lengthCounter)
                        }
                        //Calculates the new pointer to store the new word
                        ptr := add(ptr, and(add(lengthCounter, 0x40), not(0x1f)))
                        //Add to total string size
                        arrMemoryAlloc := add(arrMemoryAlloc, lengthCounter)
                        //Reset the str length
                        lengthCounter := 0
                        // counter++
                        counter := add(counter, 1)
                        //skips the delim word in subject
                        i:= add(i, delimLength)
                        continue
                    }
                }
                //Grabs chars based on pattern
                let compare := shr(pattern, xor(mload(start), mload(delim)))
                //If compare != 0 then store it to pointer current location
                if iszero(eq(compare, 0)){
                    //Store the whole in the pointer at the current location
                    mstore(add(ptr, add(0x20, lengthCounter)), mload(start))
                    //Adds one to word length
                    lengthCounter := add(lengthCounter, 1)
                    //Skips to next char
                    i:= add(i, 1)
                    continue
                }
                //If compare == 0 the check if the length is not empty
                if iszero(compare){
                    //if length != 0
                    if iszero(eq(lengthCounter, 0)){
                        //Stores 0s based on the pointer location with the length counter added so we can clean the bits that we don't care about
                        mstore(add(ptr, add(0x20, lengthCounter)), 0)
                        //Stores length at the ptr current location
                        mstore(ptr, lengthCounter)
                    }
                    //Calculates the new pointer to store the new word
                    ptr := add(ptr, and(add(lengthCounter, 0x40), not(0x1f)))
                    //Add to total string size
                    arrMemoryAlloc := add(arrMemoryAlloc, lengthCounter)
                    //Reset the str length
                    lengthCounter := 0
                    // counter++
                    counter := add(counter, 1)
                    //skips the delim word in subject
                    i:= add(i, delimLength)
                }
            }
            result := ptr
            //Stores the array length
            mstore(result, counter)
            // Allocate memory for the length and the bytes of all strings,
            mstore(0x40, add(add(result, 0x20), mul(0x20, counter)))
            //Loop to fill the result array with the pointer location for the strings
            for {let i:= 0} lt(i, counter) {i:=add(i, 1)} {
                let lenPointer := mload(copyPtr)
                //Calculates the pointer with the string location
                mstore(add(result, add(0x20, mul(0x20, i))), copyPtr)
                //Calculates the pointer with the string location based on the len stored at the first pointer location
                copyPtr := add(copyPtr, and(add(lenPointer, 0x40), not(0x1f)))
            }       
        }
    }

    // Everything down bellow is copied from solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
    // @author Copied from Solady
    function replace(
        string memory subject,
        string memory search,
        string memory replacement
    ) internal pure returns (string memory result) {
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 32)) {
                    h := keccak256(search, searchLength)
                }
                let m := shl(3, sub(32, and(searchLength, 31)))
                let s := mload(search)
                // prettier-ignore
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of 
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                // prettier-ignore
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        // prettier-ignore
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            // prettier-ignore
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)    
                        if iszero(searchLength) {
                            mstore(result, t)
                            result := add(result, 1)
                            subject := add(subject, 1)
                        }
                        // prettier-ignore
                        if iszero(lt(subject, subjectSearchEnd)) { break }
                        continue
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    // prettier-ignore
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            // prettier-ignore
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(k, 0x40), not(0x1f))))
            result := sub(result, 0x20)
            mstore(result, k)
        }
    }

    function toString(uint256 value) internal pure returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit),
            // but we allocate 0x80 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 32-byte word to store the length,
            // and 3 32-byte words to store a maximum of 78 digits. Total: 0x20 + 3 * 0x20 = 0x80.
            str := add(mload(0x40), 0x80)
            // Update the free memory pointer to allocate.
            mstore(0x40, str)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need length * 2 bytes for the digits, 2 bytes for the prefix,
            // and 32 bytes for the length. We add 32 to the total and round down
            // to a multiple of 32. (32 + 2 + 32) = 66.
            str := add(start, and(add(shl(1, length), 66), not(31)))

            // Cache the end to calculate the length later.
            let end := str

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for {} 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                length := sub(length, 1)
                // prettier-ignore
                if iszero(length) { break }
            }

            if temp {
                // Store the function selector of `HexLengthInsufficient()`.
                mstore(0x00, 0x2194895a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Compute the string's length.
            let strLength := add(sub(end, str), 2)
            // Move the pointer and write the "0x" prefix.
            str := sub(str, 0x20)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, strLength)
        }
    }

    function toHexString(uint256 value) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need 0x20 bytes for the length, 0x02 bytes for the prefix,
            // and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 2 + 0x40) is 0x80.
            str := add(start, 0x80)

            // Cache the end to calculate the length later.
            let end := str

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute the string's length.
            let strLength := add(sub(end, str), 2)
            // Move the pointer and write the "0x" prefix.
            str := sub(str, 0x20)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, strLength)
        }
    }

    function toHexString(address value) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need 32 bytes for the length, 2 bytes for the prefix,
            // and 40 bytes for the digits.
            // The next multiple of 32 above (32 + 2 + 40) is 96.
            str := add(start, 96)

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let length := 20
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                length := sub(length, 1)
                // prettier-ignore
                if iszero(length) { break }
            }

            // Move the pointer and write the "0x" prefix.
            str := sub(str, 32)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, 42)
        }
    }   
}

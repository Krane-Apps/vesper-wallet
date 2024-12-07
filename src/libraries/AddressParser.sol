// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library AddressParser {
    function parseChainSpecificAddress(
        string calldata input
    )
        internal
        pure
        returns (address parsedAddress, string memory chainIdentifier)
    {
        bytes memory b = bytes(input);
        int256 atPos = -1;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == "@") {
                atPos = int256(i);
                break;
            }
        }
        require(atPos > 0, "Invalid format");

        bytes memory addrPart = new bytes(uint256(atPos));
        for (uint256 i = 0; i < uint256(atPos); i++) {
            addrPart[i] = b[i];
        }

        bytes memory chainPart = new bytes(b.length - uint256(atPos) - 1);
        for (uint256 j = uint256(atPos) + 1; j < b.length; j++) {
            chainPart[j - uint256(atPos) - 1] = b[j];
        }

        parsedAddress = parseAddress(string(addrPart));
        chainIdentifier = string(chainPart);
    }

    function parseAddress(string memory s) internal pure returns (address) {
        bytes memory ss = bytes(s);
        require(ss.length >= 42, "Address too short");
        uint160 addr = 0;
        for (uint i = 2; i < 42; i++) {
            addr <<= 4;
            uint8 b = uint8(ss[i]);
            if ((b >= 48) && (b <= 57)) b = b - 48;
            else if ((b >= 97) && (b <= 102)) b = b - 87;
            else if ((b >= 65) && (b <= 70)) b = b - 55;
            else revert("Invalid address char");
            addr |= uint160(b);
        }
        return address(addr);
    }
}

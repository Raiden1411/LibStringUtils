# LibStringUtils

Library of string utils.

This was made with the intention of getting a better understanding of yul and evm memory management. Please don't use this in production code without more extensive tests. If you want to use a battle tested string library please check acknowledgements.
This could possibly be useful if you want to perform some test on your smart contracts that require string manipulation.

This was a really fun project and i learned a lot from it. All the code is documented with my understanding and hope you can get something out of it if you are looking to improve just like I was.

Feel free to gas golf as this is also not optimized.

## Contracts

```ml
src
├─ LibStringUtils — Library for strings
test
└─ LibStringUtils.t — Tests
```

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install Raiden1411/LibStringUtils
```

## Acknowledgements

- [femplate](https://github.com/abigger87/femplate)
- [solmate](https://github.com/transmissions11/solmate)
- [solady](https://github.com/Vectorized/solady)
- [solidity-stringutils](https://github.com/Arachnid/solidity-stringutils)


## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._

# PolyBond

[PolyBond](https://polybond.vercel.app/) is a Polygon based tool that helps any blockchain product with tokens manage their liquidity in a more sustainable way. It does this by enabling the project owners to quickly and automatically deploy a bonding system (complete with contracts, UI etc) through which users with LP Tokens can deposit them in the projects treasury in exchange for its tokens (or any payout token determined by the owners) at a discounted price.

- PolyBond can help ensure project tokens always have adequate liquidity in DEXes, even during bear markets
- Some projects using similar tools have profited massively from liquidity pool rewards
- It helps remove the risk of impermanent loss for liquidity miners

The mechanism implemented by PolyBond is called Protocol Owned Liquidity (POL) and it was pioneered by Olympus DAO. It has been termed DeFi 2.0.

[Here](https://youtu.be/ESgmX1-fAh4) is a short video explaining how PolyBond works.
[Here](https://docs.google.com/presentation/d/11J2I-2a_Mxl788OFwMz4VhndumFG2BSmNKjU_8wZeKw/edit?usp=sharing) are slides that explain Protocol-Owned Liquidity, the concept PolyBond helps execute.

Interact with PolyBond [here](https://polybond.vercel.app/).

## Tech Stack

PolyBond was built on the Polygon blockchain. It was deployed on the Mumbai testnet using Alchemy. 

### Other Tools Used
1. [Solidity](https://soliditylang.org/about/)
1. [Hardhat](https://hardhat.org/)
1. [Next.js](https://nextjs.org/learn/foundations/about-nextjs/what-is-nextjs)
1. [Tailwind CSS](https://tailwindcss.com/)

It is an [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535) compliant project. This means it follows the most up to date best practices for building software on EVM-compatible networks. Projects built with the Diamond Standard are more gas efficient, secure and flexible.

## Installation
1. Clone this repo:
```console
git clone git@github.com:name_of_organisation/name_of_repo.git
```

2. Install NPM packages:
```console
cd name_of_repo
yarn install
```

## Deployment

```console
npx hardhat run scripts/deploy.ts
```

## Run tests:
```console
npx hardhat test
```

## Useful Links
1. [Why Web3 Projects Should Move to Protocol-Owned Liquidity](https://dappradar.com/blog/why-web3-projects-should-move-to-protocol-owned-liquidity)
1. [DeFi 2.0: An Alternative Solution to Liquidity Mining](https://consensys.net/blog/cryptoeconomic-research/defi-2-0-an-alternative-solution-to-liquidity-mining/)
1. [Introduction to the Diamond Standard, EIP-2535 Diamonds](https://eip2535diamonds.substack.com/p/introduction-to-the-diamond-standard)
1. [EIP-2535 Diamonds](https://github.com/ethereum/EIPs/issues/2535)





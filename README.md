# Desurance

| Contents                            |
| ----------------------------------- |
| [Deployements](#deployements)       |
| [Details](#details)                 |
| [Smart Contracts](#smart-contracts) |
| [Tech Stack Used](#tech-stack-used) |
| [Features](#features)               |
| [Getting Started](#getting-started) |

## Deployements

Deployed website at Vercel: [Desurance](https://desurance-beta.vercel.app/)

## Details

A decentralised p2p insurance platform where users can create insurance contract and judges will be selected randomly automatically based on the contract conditions and final judgement will be fulfilled automatically after insurance finishes.

Every user can create an insurance contract, which will have following informations:

1. Title
2. Description
3. Minimum members
4. Time after which no new user can enter and insurance will start
5. validity, that is for how long insurance will remains
6. claim time: that is for how long after insurance ended, can a user make an insurance claim for their loss.
7. Percentage divided among judges
8. judging time: how much time will judge get to judge all the claims.

After an insurance contract is created, anyone who wants join a particular contract is supposed to send a request for membership. If every member of that contract accept the request then the user can add himself to the contract.

Judges are selected using **chainlink oracles**, one for getting random numbers to select judges randomly and other to perform function after certain period which is also done using oracles. So custom logic based **automation** + **random number** is used from chainlink oracles.

If no judges had fullfilled their jobs then everyone except those judges will get their fund inside the pool back. If no claim have majority votes then judges who didn't fullfilled won't get their funds back and everyone else will get their funds back. If claim request is fullfilled then remaining amount is distributed among all the members. Also first judges get their percentage from total pool amount as a prize for fullfilling their job.

Title, description, and all other texts and responses are stored on **IPFS** using **Web3.storage**.

All contracts are deployed on **polygon mumbai** testnet.

**Orbis.club** is used to provide users an ability to make comments on any insurance on **ceramic** network which is based on the **IPFS libP2P stack**.

## Smart Contracts

[Solidity files](https://github.com/Ahmed-Aghadi/desurance/tree/main/smart_contracts/contracts)

[Smart Contracts Addresses](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/constants/contractAddress.json)

### Verified Smart Contracts on polygonscan

[DesuranceHandle](https://mumbai.polygonscan.com/address/0x4682390c7Be9f4c833533dFd7E0E68356cd96909#code)

## Tech Stack Used

| Tech stack used           |
| ------------------------- |
| [Chainlink](#chainlink)   |
| [Filecoin](#filecoin)     |
| [Polygon](#polygon)       |
| [Orbis.club](#orbisclub)  |
| [Mantine UI](#mantine-ui) |

## Features

-   Provides users a p2p decentralized insurance platform which automatically does a lot of work using chainlink oracles.

-   Automatically random judges will get selected and automatically final judgement will be fulfilled using **Chainlink oracles**.

-   All the title, description, etc. are stored in **IPFS** using web3.storage

-   Users can also make comments on the insurance on **ceramic network** using **Orbis.club** which is based on the **IPFS libP2P stack**.

-   All the contracts are deployed on Polygon mumbai testnet thus providing low gas fees yet a secured chain.

## Getting Started

To run frontend :

```bash
cd client/my-app

yarn run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

To deploy smart contracts to localhost :

```bash
cd smart_contracts/

yarn hardhat deploy --network localhost
```

## Sponsors Used

### Chainlink

Chainlink was used to randomly select an image out of all images of the post while also considering rarities assigned while minting.

[checkUpkeep](https://github.com/Ahmed-Aghadi/desurance/blob/main/smart_contracts/contracts/DesuranceHandle.sol#L178)

[performUpkeep](https://github.com/Ahmed-Aghadi/desurance/blob/main/smart_contracts/contracts/DesuranceHandle.sol#L154)

[fulfillRandomWords](https://github.com/Ahmed-Aghadi/desurance/blob/main/smart_contracts/contracts/DesuranceHandle.sol#L170)

### Filecoin

Web3.storage was used to store almost all the contents (like title, description in json, etc.) and then to fetch it such that globaly everyone can see and appreciate the content in a decentralized way.

[Uploading json to IPFS](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/pages/api/json-upload-ipfs.js)

[Storing Insurance title and description as json](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/Upload.jsx#L188)

[Storing reason for Judging insurance claim request as json](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/ClaimRequests.js#L168)

[Storing description insurance claim request as json](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/InsurancePage.jsx#L316)

[Storing description for joining insurance as a member as json](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/InsurancePage.jsx#L402)

### Polygon

All the smart contracts are deployed on polygon mumbai testnet.

[Deployements](https://github.com/Ahmed-Aghadi/desurance/tree/main/smart_contracts/deployments)

[Smart Contracts](https://github.com/Ahmed-Aghadi/desurance/tree/main/smart_contracts/contracts)

### Orbis.club

Orbis is used to provide users an ability to make comments on any insurance on ceramic network which is based on the IPFS libP2P stack.

[Creating a group](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/Upload.jsx#L245)

[sending posts in the group](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/ChatBox.js#L89)

[fetching posts made in the group](https://github.com/Ahmed-Aghadi/desurance/blob/main/client/my-app/components/ChatBox.js#L108)

### Mantine UI

Mantine ui was heavily used in front end for styling.

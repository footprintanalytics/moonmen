import { ethers } from 'hardhat'
import 'dotenv/config'

const { NAME, BASE_TOKEN_URI } = process.env

async function main() {
  const contractFactory = await ethers.getContractFactory(NAME!)
  const contract = await contractFactory.deploy(BASE_TOKEN_URI)
  await contract.deployed()
  console.log('Contract deployed to:', contract.address)
}

main()

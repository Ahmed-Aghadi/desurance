import Head from "next/head"
import Image from "next/image"
import styles from "../styles/Home.module.css"
import { ethers } from "ethers"
import { AppShell, Navbar, Header } from "@mantine/core"
import { NavbarMinimal } from "../components/Navigation"
import { useAccount, useSigner } from "wagmi"
import { useRouter } from "next/router"
import { useEffect, useState } from "react"
import { desuranceHandleAbi, desuranceContractAddress } from "../constants"
import Insurances from "../components/Insurances"

export default function Home() {
    const { isConnected } = useAccount()
    const router = useRouter()
    const { data: signer, isError, isLoading } = useSigner()

    const [insurances, setInsurances] = useState([])

    useEffect(() => {
        if (signer) {
            fetchInsurances()
        }
    }, [signer])

    const fetchInsurances = async () => {
        const contractInstance = new ethers.Contract(
            desuranceContractAddress,
            desuranceHandleAbi,
            ethers.getDefaultProvider(process.env.NEXT_PUBLIC_RPC_URL)
        )
        const data = await contractInstance.getContracts()
        setInsurances(data)
        console.log("data", data)
    }

    return (
        <div className={styles.container}>
            <Insurances insurances={insurances} />
        </div>
    )
}

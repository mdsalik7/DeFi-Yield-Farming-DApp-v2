import React from 'react'
import styled from 'styled-components'
import Farmer from '../Farmer.png'

import { useUser } from '../context/UserContext'
import { useContract } from '../context/ContractContext'

const Bar = styled.nav`
    width: 100%;
    height: 4.3rem;
    background-color: #66b3ff ;
    opacity: 0.65;
`;

const Title = styled.span`
    color: black;
    font-size: 3rem;
    text-shadow: 2px 2px #ffffff

    ;
    
`;

const Address = styled.span`
    color: black;
    font-size: 1.4rem;

    display: flex;
    justify-content: center;
`;

const Network = styled(Address)`
    margin-left: 0;
    margin-right: 2rem;
`;

const Adjust = styled.div`
    display: flex;
    justify-content: space-around;
    align-items: center;
`;

const Img = styled.img`
    position: relative;
    width: 2.3rem;
    height: 2.1rem;
    margin-right: .8rem;
`;


export default function NavBar() {

    const {
        userAddress
    } = useUser()

    const {
        network
    } = useContract()

    const address = userAddress ? userAddress.slice(0, 5) + '...' + userAddress.slice(38, 42) : null


    return (
        <div>
            <Bar>
                <Adjust>
                <Title >
                        Defi Yield Farming DApp
                    </Title>
                <Network>
                        Network : {network}
                    </Network>
                    
                    
                    <Address>
                        <Img src={Farmer} />
                        Farmer : {address}
                    </Address>
                </Adjust>
            </Bar>
        </div>
    )
}

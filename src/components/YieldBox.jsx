import React from 'react'
import styled from 'styled-components'

import { useUser } from '../context/UserContext'

const YieldContainer = styled.div`
    background-color: #668cff;
    width: 30rem;
    height: 20rem;
    margin-top: 2rem;
    opacity: 0.9;
    color: white;
    font-size: 1.75rem;
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const WithdrawButton = styled.button`
    width: 15rem;
    height: 5rem;
    margin-top: 1rem;
    font-size: 2rem;
    background-color: #654321;
    color: white;
    margin-top: 2rem;
`;

const Center = styled.div`
    margin-top: 2rem;
`;

export default function YieldBox(props) {

    const {
        hodlYield,
        hodlBalance
    } = useUser()


    const withdrawYield = () => {
        props.withdrawYield()
    }


    return (
        <div className= "text-muted text-center">
            <YieldContainer className="container rounded">
                <Center>
                    Hodl Balance : {hodlBalance}
                    <div/>
                    Hodl Yield : {hodlYield}
                    <div/>
                    <WithdrawButton onClick={withdrawYield} className="btn btn-danger btn-block btn-lg">
                        Withdraw!
                    </WithdrawButton>
                </Center>
            </YieldContainer>
        </div>
    )
}

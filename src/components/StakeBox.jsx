import React, { useState } from 'react'
import styled from 'styled-components'

import { useUser } from '../context/UserContext'

const StakeContainer = styled.div`
    background-color:  #668cff;
    width: 30rem;
    height: 20rem;
    margin-top: 2rem;
    opacity: 0.9;
    color: white;
    font-size: 2rem;
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const StakeInput = styled.input`
    height: 2.6rem;
    width: 10rem;
    margin-top: 2.5rem;
    
`;

const StakeButton = styled.button`
    width: 10rem;
    height: 3.7rem;
    margin-top: 0rem;
    background-color: green;
    color: white;
    font-size: 1.4rem;
`;

const Center = styled.div`
    margin-top: 2rem;
`;

const Div = styled.div`
    display: flex;
    align-items: center;
`;

const UnstakeButton = styled(StakeButton)``;

export default function StakeBox(props) {

    const {
        daiBalance,
        stakingBalance,
    } = useUser()

    
    const [ stakeAmount, setStakeAmount ] = useState('');


    const stake = async() => {
        props.stake(stakeAmount)
    }

    const handleStake = (event) => {
        setStakeAmount(event.target.value)
    }

    const unstake = () => {
        props.unstake()
    }

    return (
        <div className= "text-muted text-center">
            <StakeContainer className="container rounded">
                <Center>
                    Staked Balance : {stakingBalance}
                    <div/>
                    Dai Balance : {daiBalance}
                    <Div>
                        <div>
                        <StakeInput onChange={handleStake} placeholder="  Amount" className="form-control form-control-lg"/>
                        </div>
                        <div>
                        <StakeButton onClick={stake} className="btn btn-primary btn-block btn-lg">
                            STAKE!
                        </StakeButton>
                        </div>
                    </Div>
                    <UnstakeButton onClick={unstake} className="btn btn-secondary btn-block btn-lg float-right">
                        Un-Stake..
                    </UnstakeButton>
                </Center>
            </StakeContainer>
        </div>
    )
}

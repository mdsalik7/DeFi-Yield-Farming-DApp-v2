import React, { useContext } from 'react'

/*Context provides a way to pass data through the component tree without
having to pass props down manually at every level.*/
/*
In a typical React application, data is passed top-down (parent to child) via props, but this can be cumbersome
for certain types of props (e.g. locale preference, UI theme) that are required by many components within an 
application. Context provides a way to share values like these between components without having to explicitly 
pass a prop through every level of the tree.
*/
/*Context is primarily used when some data needs to be accessible by many components at different nesting levels.
Apply it sparingly because it makes component reuse more difficult.*/
export const ContractContext = React.createContext({
    hodlFarmAddress: '',
    setHodlFarmAddress: () => {},
    hodlTokenAddress: '',
    setHodlTokenAddress: () => {},
    daiAddress: '',
    setDaiAddress: () => {},
    hodlFarm: '',
    setHodlFarm: () => {},
    hodlToken: '',
    setHodlToken: () => {},
    dai: '',
    setDai: () => {},
    hodlFarmBalance: '',
    setHodlFarmBalance: () => {},
    network: '',
    setNetwork: () => {},
    web3: '',
    setWeb3: () => {},
    //calls to update balances
    sentStake: '',
    setSentStake: () => {},
    sentUnstake: '',
    setSentUnstake: () => {},
    sentWithdrawal: '',
    setSentWithdrawal: () => {}
})

export const ContractProvider = ContractContext.Provider
export const useContract = () => useContext(ContractContext)
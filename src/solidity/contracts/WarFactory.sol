pragma solidity ^0.4.18;
import { CoinWar } from "./CoinWar.sol";

contract WarFactory {

  struct War {
    string opponents;
    CoinWar coinWar;
    bool isOngoing;
  }

  War[] public allWars;
  uint public ongGoingWars;

  address public owner;
  event WarClosed(uint index);
  event NewWarCreated(string opponents);

  function WarFactory()
    public
  {
    owner = msg.sender;
  }

  function createCoinWar(string _opponents, address _tokeOne, address _tokenTwo, uint _fromBlock, uint _toBlock)
    public
    onlyOwner
  {
    ongGoingWars += 1;
    CoinWar newWar = new CoinWar(_tokeOne, _tokenTwo, _fromBlock, _toBlock);
    allWars.push(War(_opponents, newWar, true));
    NewWarCreated(_opponents);
  }

  function closeWarAtIndex(uint index, address[] winningAddresses, uint[] winningBets, address winningContract, address[] loosingAddresses, uint[] loosingBets, address loosingContract)
    public
    onlyOwner
  {
    ongGoingWars -= 1;
    allWars[index].isOngoing = false;
    CoinWar(allWars[index].coinWar).setResults(winningAddresses, winningBets, winningContract, loosingAddresses, loosingBets, loosingContract);
    WarClosed(index);
  }

  function getWarAtIndex(uint index)
    public
    view
    returns (string,address, address, uint, uint, uint, uint, address)
  {
    CoinWar coinWar = CoinWar(allWars[index].coinWar);
    var (balance1, balance2) = coinWar.getUserBalance(msg.sender);
    return (allWars[index].opponents, address(coinWar.token1()), address(coinWar.token2()), balance1, balance2, coinWar.fromBlock(), coinWar.toBlock(), address(coinWar));
  }

  function isWarClosedAtIndex(uint index) public view returns (bool, address) {
    CoinWar coinWar = CoinWar(allWars[index].coinWar);
    return (allWars[index].isOngoing, address(coinWar));
  }

  function getResultsAtIndexForUser(uint index, address user)
    public
    view
    returns (string, uint, uint, uint, uint, uint, address)
  {
    CoinWar coinWar = CoinWar(allWars[index].coinWar);
    var (winnerIndex, winningBet, loosingBet, totalWinningBet, totalLoosingBet) = coinWar.getUserBet(user);

    return (allWars[index].opponents, winnerIndex, winningBet, loosingBet, totalWinningBet, totalLoosingBet, address(coinWar));

  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _ ;
  }

  function getWarsCount() public view returns (uint) {
    return allWars.length;
  }

}

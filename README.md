# SelfDestructTrap

A smart contract monitoring system designed to detect self-destruct attacks and suspicious ETH transfers targeting specific wallet addresses.

## Overview

The SelfDestructTrap contract implements the ITrap interface from Drosera contracts to monitor and detect potential self-destruct attacks on Ethereum wallets. It analyzes balance changes and transaction patterns to identify malicious activities such as forced ETH transfers and dusting attacks.

## Use Cases

### 1. **Self-Destruct Attack Detection**

**Problem**: Malicious contracts can force ETH transfers to any address using the `selfdestruct` function, bypassing normal transaction mechanisms and potentially:
- Disrupting contract logic that assumes certain balance states
- Forcing unwanted ETH onto contracts with strict balance requirements
- Creating unexpected state changes in monitored addresses

**Solution**: The trap detects sudden balance increases without corresponding normal transactions (nonce unchanged), indicating a potential self-destruct attack.

**Example Scenario**:
```
Target Wallet: 0x1234...7890
Time T1: Balance = 1.0 ETH, Nonce = 50
Time T2: Balance = 2.5 ETH, Nonce = 50 (No outgoing transaction!)
→ ALERT: Self-destruct attack detected
```

### 2. **Smart Contract Security Monitoring**

**Problem**: DeFi protocols and smart contracts often have specific balance requirements or assumptions. Unexpected ETH deposits can:
- Break invariants in lending protocols
- Affect reward calculations in staking contracts
- Disrupt automated market maker algorithms
- Trigger unintended contract behaviors

**Solution**: Continuous monitoring alerts administrators when unexpected ETH appears in critical contract addresses.

**Real-World Applications**:
- **DeFi Protocols**: Monitor treasury or vault contracts
- **DAO Treasuries**: Detect unauthorized fund movements
- **Multi-sig Wallets**: Alert on unexpected balance changes
- **Smart Contract Auditing**: Real-time security monitoring

### 3. **Dusting Attack Prevention**

**Problem**: Attackers send small amounts of ETH (dust) to many addresses to:
- Track user activity and link addresses
- Compromise privacy and anonymity
- Prepare for larger attacks
- Waste gas on cleanup transactions

**Solution**: The trap identifies suspicious small amounts (between 0.000001 and 0.01 ETH) that may indicate dusting attempts.

**Detection Criteria**:
- Balance in dusting range: `0.000001 ETH < balance < 0.01 ETH`
- Unexpected appearance of small amounts
- Pattern analysis across multiple transactions

### 4. **Forensic Analysis and Investigation**

**Problem**: After security incidents, investigators need to:
- Trace the source and method of attacks
- Understand attack vectors and timing
- Provide evidence for legal proceedings
- Prevent similar future attacks

**Solution**: The trap provides detailed logging with timestamps, balance changes, and detection reasons for comprehensive forensic analysis.

**Forensic Data Includes**:
- Wallet address and balance history
- Timestamp of suspicious activities
- Detection reason and threat classification
- Transaction pattern analysis

### 5. **Compliance and Regulatory Monitoring**

**Problem**: Financial institutions and regulated entities need to:
- Monitor for suspicious transaction patterns
- Comply with AML (Anti-Money Laundering) requirements
- Report unusual activities to authorities
- Maintain audit trails

**Solution**: Automated monitoring and alerting system that can be integrated into compliance workflows.

**Compliance Features**:
- Real-time monitoring of designated addresses
- Automated threat classification
- Detailed audit logs with timestamps
- Integration-ready response system

### 6. **MEV (Maximal Extractable Value) Protection**

**Problem**: MEV bots and malicious actors can:
- Manipulate contract states through forced ETH transfers
- Front-run transactions by altering expected balances
- Extract value from unsuspecting users
- Disrupt normal contract operations

**Solution**: Early detection of balance manipulation attempts allows for protective measures.

**Protection Mechanisms**:
- Real-time balance monitoring
- Pattern recognition for MEV attacks
- Integration with circuit breaker systems
- Automated response triggers

### 7. **Insurance and Risk Management**

**Problem**: DeFi insurance providers and risk managers need:
- Real-time risk assessment of covered protocols
- Early warning systems for potential claims
- Automated threat detection and classification
- Historical data for actuarial analysis

**Solution**: Continuous monitoring provides risk signals and early warning indicators.

**Risk Management Applications**:
- Protocol health monitoring
- Claim prevention and early intervention
- Risk scoring and premium calculation
- Automated policy enforcement

## Technical Implementation

### Key Features

- **Constant Target Monitoring**: Focuses on a specific wallet address for efficient monitoring
- **Historical Pattern Analysis**: Compares current state with previous data points
- **Multi-Criteria Detection**: Uses balance changes, timing, and transaction patterns
- **Flexible Response System**: Returns detailed information for downstream processing

### Detection Algorithms

1. **Balance Increase Without Transaction**: Detects balance increases without nonce changes
2. **Timing Analysis**: Flags rapid changes (< 5 minutes) as suspicious
3. **Amount Thresholds**: Uses configurable thresholds for different attack types
4. **Pattern Recognition**: Analyzes historical data for attack patterns

### Integration Points

- Compatible with Drosera monitoring infrastructure
- Standard ITrap interface for easy integration
- Customizable detection parameters
- Extensible for additional monitoring criteria

## Configuration

The contract currently monitors:
- **Target Address**: `0x1234567890123456789012345678901234567890` (configurable)
- **Minimum Suspicious Amount**: `0.001 ETH`
- **Time Window**: `300 seconds (5 minutes)`
- **Dusting Range**: `0.000001 ETH - 0.01 ETH`

## Response Data Format

When a threat is detected, the contract returns:
```solidity
struct ResponseData {
    address wallet;        // Monitored wallet address
    uint256 balance;       // Current balance
    uint256 timestamp;     // Detection timestamp
    string reason;         // Human-readable detection reason
    bool is_threat;        // Threat classification flag
}
```

## Future Enhancements

- **Multi-Address Monitoring**: Extend to monitor multiple addresses simultaneously
- **Machine Learning Integration**: Implement ML-based pattern recognition
- **Cross-Chain Support**: Expand monitoring to other blockchain networks
- **Dynamic Thresholds**: Implement adaptive threshold adjustment
- **Integration APIs**: Develop REST APIs for external system integration

## Security Considerations

- The contract uses `view` functions for data collection and `pure` functions for analysis to prevent state manipulation
- All calculations are performed with proper overflow protection
- Historical data comparison ensures robust detection
- Configurable parameters allow for fine-tuning detection sensitivity

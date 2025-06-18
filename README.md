# Event Ticket NFT Contract

A Clarity smart contract for managing event tickets as NFTs, providing secure ticket issuance, transfer, and validation on the Stacks blockchain.

## Overview

This contract revolutionizes event ticketing by creating tamper-proof digital tickets as NFTs. Event organizers can issue tickets, attendees can transfer them securely, and tickets can be validated at event entry.

## Features

- **Ticket Creation**: Issue unique NFT tickets for events
- **Secure Transfers**: Transfer tickets with usage validation
- **Entry Validation**: Mark tickets as used upon event entry
- **Event Management**: Activate/deactivate events for ticket validation
- **Tier Support**: Support for different ticket tiers (VIP, General, etc.)
- **SIP-009 Compliance**: Full compatibility with Stacks NFT standard

## Contract Functions

### Public Functions

- `create-ticket`: Create new event ticket (organizer only)
- `transfer`: Transfer ticket ownership (unused tickets only)
- `use-ticket`: Mark ticket as used for event entry
- `activate-event`: Activate event for ticket validation

### Read-Only Functions

- `get-ticket-information`: Retrieve ticket details
- `get-owner`: Get current ticket holder
- `get-last-token-id`: Get the latest ticket ID

## Usage

1. Deploy contract as event organizer
2. Create tickets using `create-ticket` for buyers
3. Buyers can transfer tickets before use
4. Activate event using `activate-event`
5. Validate tickets at entry using `use-ticket`

## Security

- Only organizer can create tickets and activate events
- Used tickets cannot be transferred
- Tickets can only be used when event is active

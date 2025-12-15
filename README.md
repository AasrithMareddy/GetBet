# GetBet

A simple iOS app to track friendly bets with friends—featuring dispute resolution through neutral middlemen and email/Google authentication.

## Overview

GetBet helps you keep track of casual bets made between friends—whether it's sports outcomes, personal predictions, or playful wagers. The app includes a built-in dispute resolution system: if participants disagree on who won, an optional middleman can step in to make the final call. No more forgotten bets or arguments about outcomes.

## Features

### Authentication
- **Email Sign-Up**: Create an account with email verification
- **Google Sign-In**: Quick authentication using Google OAuth
- **Secure Login**: Persistent session management

### Bet Management
- **Create Bets**: Set up bets with participants, stakes, conditions, and deadlines
- **Middleman System**: Assign an optional neutral third-party to resolve disputes
- **Invite System**: All participants and middlemen receive invites to accept or decline bets
- **Track Status**: Monitor active, pending, and settled bets in real-time
- **Settlement Logic**: 
  - If both participants agree on the winner, bet is auto-settled
  - If there's a disagreement, the middleman declares the final result
- **Bet History**: Complete record of all past bets with outcomes and timestamps

### Upcoming Features
- **Live Sports API Integration**: Real-time odds and automatic settlement based on sports results (in development)

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Authentication**: Firebase Authentication (Google OAuth + Email/Password with verification)
- **Backend**: Firebase (Authentication, Realtime Database/Firestore)
- **Platform**: iOS

## Installation

### Requirements
- Xcode 14.0+
- iOS 15.0+
- macOS 12.0+ (for development)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/AasrithMareddy/GetBet.git
cd GetBet
```

2. Open the project in Xcode:
```bash
open GetBet.xcodeproj
```

3. Build and run the project (⌘ + R)

## Usage

1. **Sign Up / Sign In**
   - Create an account using email (with verification) or Google OAuth
   
2. **Create a Bet**
   - Set bet details: title, stakes, conditions, deadline
   - Add participants
   - Optionally assign a middleman to resolve disputes
   
3. **Accept/Decline Invites**
   - All participants and middlemen receive invitations
   - Accept to join, decline to opt out
   
4. **Track Active Bets**
   - View all ongoing bets on the home screen
   - Monitor bet status and deadlines
   
5. **Settle Bets**
   - Both participants select a winner
   - If disagreement occurs, middleman declares the result
   - Bet automatically closes once consensus is reached
   
6. **View History**
   - Access complete bet history with outcomes and dates

## Project Status

This is a personal project built to explore SwiftUI and iOS development while solving a real-world problem of tracking informal bets between friends.

## Future Improvements

- **Live Sports API**: Integrate real-time sports data for automatic bet settlement
- **Push Notifications**: Alerts for bet invites, deadlines, and settlements
- **Betting Statistics**: Track win/loss records and betting trends
- **Group Bets**: Support multiple participants in a single bet
- **Photo Attachments**: Add proof or context to bets
- **Leaderboards**: Competitive rankings among friend groups
- **Dark Mode**: Enhanced UI theming

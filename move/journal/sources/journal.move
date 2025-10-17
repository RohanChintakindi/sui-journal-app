// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Journal application that allows users to create personal journals and add entries.
/// Each journal is an owned object, making it private and gas-efficient.
module journal::journal {
    use std::string::String;
    use sui::clock::Clock;

    /// A journal entry with content and timestamp
    public struct Entry has store {
        content: String,
        created_at_ms: u64,
    }

    /// An owned journal object that belongs to a specific user
    public struct Journal has key, store {
        id: UID,
        owner: address,
        title: String,
        entries: vector<Entry>,
    }

    /// Creates a new journal with the given title
    public fun new_journal(title: String, ctx: &mut TxContext): Journal {
        Journal {
            id: object::new(ctx),
            owner: ctx.sender(),
            title,
            entries: vector::empty<Entry>(),
        }
    }

    /// Entry function to create and transfer a new journal to the sender
    public entry fun create_journal(title: String, ctx: &mut TxContext) {
        let journal = new_journal(title, ctx);
        transfer::transfer(journal, ctx.sender());
    }

    /// Adds a new entry to the journal
    /// Only the journal owner can add entries
    public fun add_entry(
        journal: &mut Journal,
        content: String,
        clock: &Clock,
        ctx: &TxContext
    ) {
        // Verify the caller is the journal owner
        assert!(journal.owner == ctx.sender(), 0);

        // Create a new entry with the current timestamp
        let entry = Entry {
            content,
            created_at_ms: clock.timestamp_ms(),
        };

        // Add the entry to the journal
        journal.entries.push_back(entry);
    }
}

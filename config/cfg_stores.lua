Config.Stores = {
    ["methanol_vendor"] = {
        name = "Not Shady Ace",
        coords = vec4(0.0, 0.0, 0.0, 0.0),
        pedModel = "cs_old_man2",
        icon = "flask",
        idleScenario = "WORLD_HUMAN_SMOKING",
        items = {
            {itemName = "methanol", label = "Methanol", basePrice = 500, minPrice = 350, stock = 10}
        },
        welcome = "Looking for some high-grade chemicals, or just browsing?",
        choices = {
            ["friendly"] = {
                label = "Be Polite",
                emote = "wave",
                npcSuccessDict = "anim@mp_player_intincarthumbs_uplow@ds@",
                npcSuccessAnim = "enter",
                npcFailDict = "mp_common",
                npcFailAnim = "no_way",
                gender = {"male", "female"},
                dialogue = {
                    male = "Hey, I come here often. Could you cut me a small deal?",
                    female = "Hi there! I come here often. Can you give me a friendly deal?"
                },
                chance = 75,
                multiplier = 0.90,
                success = {
                    male = "Since it's you, I'll knock a bit off the top. Happy to help.",
                    female = "For you, I'll give a little discount. Pleasure doing business."
                },
                failReply = {
                    male = "I like you, kid, but business is business. Price stays as is.",
                    female = "I like your style, but my price stays firm."
                },
                noMoney = {
                    male = "I'd love to help a friend out, but you don't even have the cash!",
                    female = "I'd help if you had the money, but you're empty-handed!"
                }
            },
            ["barter"] = {
                label = "Negotiate",
                emote = "argue",
                npcSuccessDict = "mp_ped_interaction",
                npcSuccessAnim = "handshake_guy_a",
                npcFailDict = "amb@world_human_hang_out_street@male_c@idle_a",
                npcFailAnim = "idle_b",
                gender = {"male", "female"},
                dialogue = {
                    male = "I know other suppliers, but I prefer your stuff. Any chance for a better price?",
                    female = "I like your products, but can you offer me a better price?"
                },
                chance = 40,
                multiplier = 0.75,
                success = {
                    male = "You're persistent, I'll give you that. Fine.",
                    female = "Alright, you drive a hard bargain. Deal."
                },
                failReply = {
                    male = "Other suppliers? Go ahead then. My price is firm.",
                    female = "You can look elsewhere, my price won't change."
                },
                noMoney = {
                    male = "Talk is cheap, but these chemicals aren't. Show me the money.",
                    female = "Nice chat, but you need the cash first."
                }
            },
            ["intimidate"] = {
                label = "Pressure Them",
                emote = "point",
                npcSuccessDict = "anim@scripted@bty2@ig2_beat_target@male@",
                npcSuccessAnim = "leaning_idle_bounty",
                npcFailDict = "mp_bank_heist_1",
                npcFailAnim = "fear_reaction",
                gender = {"male", "female"},
                dialogue = {
                    male = "Cut the chit-chat. Methanol at a good price, now.",
                    female = "Cut the small talk. Methanol at a fair price, now."
                },
                chance = 15,
                multiplier = 0.60,
                lockoutOnFail = true,
                success = {
                    male = "Alright, alright! Take it at that price, just don't cause any trouble.",
                    female = "Okay, okay! I'll give you that price, no trouble."
                },
                failReply = {
                    male = "You think you can strong-arm me? Step back before I call tazz!",
                    female = "Trying to intimidate me? Back off before things get messy!"
                },
                noMoney = {
                    male = "Trying to act tough with empty pockets? Get out of here.",
                    female = "Empty pockets won't scare me. Step aside."
                }
            },
            ["flirt"] = {
                label = "Flirt",
                emote = "blowkiss",
                npcSuccessDict = "anim@mp_player_intcelebrationfemale@blow_kiss",
                npcSuccessAnim = "blow_kiss",
                npcFailDict = "fix_trip3_mcs1-9", 
                npcFailAnim = "cs_marnie_dual-9",
                gender = {"female"},
                dialogue = {
                    female = "Hey there, I think we could make a great deal together"
                },
                chance = 50,
                multiplier = 0.85,
                success = {
                    female = "Hehe... you're mine now. I can make this deal... unforgettable."
                },
                failReply = {
                    female = "Don't play hard to get. I always get what I want."
                },
                noMoney = {
                    female = "Maybe you can pay with something else?... "
                }
            }
        }
    }
}

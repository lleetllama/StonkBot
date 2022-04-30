

def create_stonks
    Stonk.create(
        id: 1,
        stonk_name: "FEET",
        keywords:  %w( arch digit digits feet fingers foot hands heel knee leg legs pace palm run shoe sole toe toenail toes walk stomp step ).join(','),
        base_value: "100",
        volatility: "3"
    ).save
    Stonk.create(
        id: 2,
        stonk_name: "DND",
        keywords:  [ 
            "Matthew", "dickbutt", "dnd", 
            "dragon", "dungeon", "treasure", 
            "npc", "loot", "adventure", "DM", 
            "story writing", "Critical Role",
            "Travis"
        ].join(','),
        base_value: "100",
        volatility: "3"
    ).save
    Stonk.create(
        id: 3,
        stonk_name: "GLIZZ",
        keywords:  %w( dog hotdog glizzy weener weiner penis donk dick dinker phallus ).join(','),
        base_value: "100",
        volatility: "3"
    ).save
end
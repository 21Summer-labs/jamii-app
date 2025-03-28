
products = [
    # Mechanic Store - AutoFix Garage (S001)
    Product("P001", "S001", "Engine Oil", "High-quality synthetic engine oil.", 15.99, "mechanic", "lubricants", 50, ["oil", "engine", "car"], [], ""),
    Product("P002", "S001", "Car Battery", "12V durable battery for vehicles.", 89.99, "mechanic", "batteries", 20, ["battery", "car", "vehicle"], [], ""),
    Product("P003", "S001", "Brake Pads", "Long-lasting brake pads for safety.", 49.99, "mechanic", "brakes", 30, ["brakes", "safety", "auto"], [], ""),
    Product("P004", "S001", "Car Jack", "Hydraulic jack with 2-ton capacity.", 29.99, "mechanic", "tools", 15, ["car", "jack", "tools"], [], ""),
    Product("P005", "S001", "Spark Plugs", "Set of 4 premium spark plugs.", 19.99, "mechanic", "engine parts", 40, ["engine", "spark plug", "auto"], [], ""),

    # Welding & Repairs - WeldPro Works (S002)
    Product("P006", "S002", "Welding Helmet", "Auto-darkening welding helmet.", 79.99, "welding", "safety", 10, ["helmet", "safety", "welding"], [], ""),
    Product("P007", "S002", "Arc Welding Machine", "Portable 200A arc welder.", 199.99, "welding", "equipment", 5, ["welder", "machine", "arc"], [], ""),
    Product("P008", "S002", "Welding Gloves", "Heat-resistant leather gloves.", 24.99, "welding", "safety", 25, ["gloves", "safety", "heat"], [], ""),
    Product("P009", "S002", "Welding Rods", "Pack of 50 high-quality rods.", 34.99, "welding", "materials", 30, ["rods", "electrodes", "welding"], [], ""),
    Product("P010", "S002", "Metal Cutter", "Plasma cutter for precision cuts.", 299.99, "welding", "tools", 8, ["cutter", "plasma", "metal"], [], ""),

    # Tattooing - Ink Haven Tattoo (S003)
    Product("P011", "S003", "Tattoo Machine", "Rotary tattoo machine for professionals.", 159.99, "tattooing", "equipment", 12, ["machine", "tattoo", "ink"], [], ""),
    Product("P012", "S003", "Tattoo Ink Set", "Complete set of 20 vibrant colors.", 79.99, "tattooing", "inks", 20, ["ink", "tattoo", "colors"], [], ""),
    Product("P013", "S003", "Sterile Needles", "Pack of 50 sterilized needles.", 29.99, "tattooing", "needles", 30, ["needles", "sterile", "tattoo"], [], ""),
    Product("P014", "S003", "Tattoo Chair", "Adjustable chair for clients.", 199.99, "tattooing", "furniture", 6, ["chair", "tattoo", "studio"], [], ""),
    Product("P015", "S003", "Aftercare Balm", "Healing balm for tattoo aftercare.", 14.99, "tattooing", "care", 40, ["aftercare", "tattoo", "healing"], [], ""),

    # Electricals - ElectroFix (S004)
    Product("P016", "S004", "LED Light Bulbs", "Energy-saving LED bulbs.", 9.99, "electricals", "lighting", 100, ["LED", "bulb", "lighting"], [], ""),
    Product("P017", "S004", "Circuit Breaker", "High-quality 32A circuit breaker.", 49.99, "electricals", "safety", 20, ["breaker", "safety", "electric"], [], ""),
    Product("P018", "S004", "Multimeter", "Digital multimeter for diagnostics.", 39.99, "electricals", "tools", 15, ["multimeter", "electric", "testing"], [], ""),
    Product("P019", "S004", "Extension Cord", "6-socket extension with surge protection.", 19.99, "electricals", "accessories", 30, ["extension", "power", "surge"], [], ""),
    Product("P020", "S004", "Solar Panel", "100W portable solar panel.", 129.99, "electricals", "renewable energy", 8, ["solar", "energy", "green"], [], ""),

    # Computers - Tech Gear (S005)
    Product("P021", "S005", "Gaming Laptop", "High-performance gaming laptop.", 1299.99, "computers", "laptops", 5, ["laptop", "gaming", "PC"], [], ""),
    Product("P022", "S005", "Mechanical Keyboard", "RGB mechanical gaming keyboard.", 99.99, "computers", "accessories", 20, ["keyboard", "gaming", "mechanical"], [], ""),
    Product("P023", "S005", "Wireless Mouse", "Ergonomic wireless mouse.", 29.99, "computers", "accessories", 30, ["mouse", "wireless", "ergonomic"], [], ""),
    Product("P024", "S005", "External Hard Drive", "1TB USB 3.0 external storage.", 89.99, "computers", "storage", 15, ["hard drive", "storage", "USB"], [], ""),
    Product("P025", "S005", "Graphics Card", "RTX 3060 12GB GPU for gaming.", 399.99, "computers", "hardware", 8, ["GPU", "graphics", "gaming"], [], "")
]

stores = [
    Store("S001", "U001", "AutoFix Garage", "Expert mechanic services and car repairs.", {"latitude": -1.286389, "longitude": 36.817223}),
    Store("S002", "U002", "WeldPro Works", "Quality welding and repair solutions for homes and industries.", {"latitude": -1.2921, "longitude": 36.8219}),
    Store("S003", "U003", "Ink Haven Tattoo", "Professional tattooing and piercing studio.", {"latitude": -1.3032, "longitude": 36.8267}),
    Store("S004", "U004", "ElectroFix", "Electrical repairs and installations with top-notch safety.", {"latitude": -1.2853, "longitude": 36.8204}),
    Store("S005", "U005", "Tech Gear", "Computers, accessories, and repair services.", {"latitude": -1.2906, "longitude": 36.8147})
]
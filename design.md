# Domain Model for Jamii Marketplace

## Bounded Contexts

### Identity and Access Management
This context handles user management and authentication.

#### Aggregates

1. User (Aggregate Root)
   - Properties:
     - UserId (Value Object)
     - Email
     - PhoneNumber
     - Password (hashed)
     - UserProfile (Value Object)
     - UserType (Enum: SHOPPER, STORE_OWNER)
     - Status (Enum: ACTIVE, INACTIVE, SUSPENDED)
   - Behaviors:
     - Register()
     - UpdateProfile()
     - ChangePassword()
     - Deactivate()

2. UserProfile (Value Object)
   - Properties:
     - FullName
     - Location (Value Object)
     - PreferredLanguage
     - JoinDate
     - LastLoginDate

### Store Management
This context handles store-related operations.

#### Aggregates

1. Store (Aggregate Root)
   - Properties:
     - StoreId (Value Object)
     - OwnerId (reference to User)
     - StoreName
     - Description
     - Location (Value Object)
     - BusinessHours (Value Object)
     - Category (Value Object)
     - Status (Enum: ACTIVE, INACTIVE, SUSPENDED)
     - Rating
     - VerificationStatus (Enum: PENDING, VERIFIED, REJECTED)
   - Behaviors:
     - Create()
     - Update()
     - UpdateBusinessHours()
     - UpdateLocation()
     - Verify()
     - Suspend()

2. Location (Value Object)
   - Properties:
     - Latitude
     - Longitude
     - Address
     - City
     - Country
   - Behaviors:
     - CalculateDistance()

3. BusinessHours (Value Object)
   - Properties:
     - WeeklySchedule (array of DaySchedule)
   - Behaviors:
     - IsOpen()
     - GetNextOpeningTime()

### Product Management
This context handles product-related operations.

#### Aggregates

1. Product (Aggregate Root)
   - Properties:
     - ProductId (Value Object)
     - StoreId (reference to Store)
     - Name
     - Description
     - Price (Money Value Object)
     - Category
     - Tags (array of strings)
     - Images (array of ImageData Value Object)
     - Stock
     - Status (Enum: AVAILABLE, OUT_OF_STOCK, DISCONTINUED)
     - Ratings
   - Behaviors:
     - Create()
     - Update()
     - UpdateStock()
     - AddImages()
     - UpdatePrice()
     - AddTags()

2. Money (Value Object)
   - Properties:
     - Amount
     - Currency
   - Behaviors:
     - Add()
     - Subtract()
     - MultiplyBy()

### Order Management
This context handles shopping cart and order operations.

#### Aggregates

1. ShoppingCart (Aggregate Root)
   - Properties:
     - CartId (Value Object)
     - UserId (reference to User)
     - Items (List of CartItem Value Objects)
     - CreatedAt
     - UpdatedAt
   - Behaviors:
     - AddItem()
     - RemoveItem()
     - UpdateQuantity()
     - Clear()
     - CalculateTotal()

2. CartItem (Value Object)
   - Properties:
     - ProductId (reference to Product)
     - Quantity
     - Price (Money Value Object)
   - Behaviors:
     - CalculateSubtotal()

## Domain Events

1. StoreCreated
   - StoreId
   - OwnerId
   - Timestamp

2. ProductAdded
   - ProductId
   - StoreId
   - Timestamp

3. StoreVerified
   - StoreId
   - VerifierId
   - Timestamp

4. ProductOutOfStock
   - ProductId
   - StoreId
   - Timestamp

5. UserRegistered
   - UserId
   - UserType
   - Timestamp

## Domain Services

1. ProductSearchService
   - SearchByText(query, location, filters)
   - SearchByImage(image, location, filters)
   - SearchByVoice(audioInput, location, filters)

2. StoreDiscoveryService
   - FindNearbyStores(location, radius, filters)
   - GetStoreRecommendations(userId, location)

3. ProductTaggingService
   - GenerateTagsFromImage(image)
   - GenerateTagsFromDescription(description)

4. LocationService
   - ValidateLocation(location)
   - CalculateDistance(location1, location2)
   - GetDirections(fromLocation, toLocation)
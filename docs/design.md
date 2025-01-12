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
     - Images (array of ImageData Value Object)
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


### Communication

#### Aggregates

1. Conversation (Aggregate Root)
   - Properties:
     - ConversationId (Value Object)
     - ShopperId (reference to User)
     - StoreOwnerId (reference to User)
     - StoreId (reference to Store)
     - Status (Enum: ACTIVE, ARCHIVED, BLOCKED)
     - CreatedAt
     - LastMessageAt
   - Behaviors:
     - Create()
     - Archive()
     - Block()
     - Unblock()
     - UpdateLastMessageTime()

2. Message (Entity)
   - Properties:
     - MessageId (Value Object)
     - ConversationId (reference to Conversation)
     - SenderId (reference to User)
     - Content (Value Object)
     - Status (Enum: SENT, DELIVERED, READ)
     - Timestamp
     - Type (Enum: TEXT, IMAGE, PRODUCT_SHARE)
   - Behaviors:
     - Send()
     - MarkAsDelivered()
     - MarkAsRead()

3. MessageContent (Value Object)
   - Properties:
     - Text
     - MediaUrl (optional)
     - ProductReference (optional reference to Product)
   - Behaviors:
     - Validate()
     - Sanitize()

## Domain Events

Product searched
Store viewed
Product viewed
Directions accessed


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

5. ChatService
   - InitiateConversation(shopperId, storeId)
   - SendMessage(conversationId, senderId, content)
   - GetConversationHistory(conversationId, pagination)
   - GetActiveConversations(userId)
   - SearchConversations(userId, query)


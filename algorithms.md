# Domain Services Algorithms

## 1. ProductSearchService

### SearchByText(query, location, filters)
```
1. Preprocess input:
   - Sanitize and normalize text query
   - Validate location coordinates
   - Validate filter parameters

2. Generate search vectors:
   - Convert query to embedding using LLM
   - Extract key terms for traditional search

3. Execute multi-stage search:
   a. Geographic filter:
      - Get stores within specified radius of location
      - Filter by store operating hours if specified
   
   b. Semantic search:
      - Compare query embedding against product embeddings
      - Rank results by semantic similarity
   
   c. Traditional search:
      - Match against product names, descriptions, and tags
      - Apply BM25 or similar ranking algorithm

4. Apply business filters:
   - Price range
   - Category
   - Availability
   - Store rating
   - Distance

5. Merge and rank results:
   - Combine semantic and traditional search results
   - Apply distance-based decay factor
   - Sort by final composite score

6. Return paginated results with:
   - Product details
   - Store information
   - Distance
   - Availability status
```

### SearchByImage(image, location, filters)
```
1. Preprocess image:
   - Validate format and size
   - Compress if needed
   - Extract EXIF data if relevant

2. Generate image features:
   - Use vision model to extract:
     * Object detection
     * Color analysis
     * Text from image (OCR)
     * Style characteristics
   - Generate image embedding

3. Convert visual features to searchable attributes:
   - Map detected objects to product categories
   - Extract relevant tags
   - Generate natural language description

4. Execute multi-modal search:
   a. Image similarity search:
      - Compare image embedding against product image database
      - Rank by visual similarity
   
   b. Attribute-based search:
      - Use extracted tags and categories
      - Match against product metadata

5. Apply geographic and business filters (same as text search)

6. Return ranked results with:
   - Visual similarity score
   - Matched attributes
   - Standard product and store information
```

## 2. StoreDiscoveryService

### FindNearbyStores(location, radius, filters)
```
1. Validate and process inputs:
   - Verify location coordinates
   - Convert radius to appropriate units
   - Validate filter parameters

2. Execute spatial query:
   - Use geospatial index to find stores within radius
   - Apply R-tree or similar spatial index structure
   - Calculate precise distances

3. Apply filters:
   - Operating hours
   - Store categories
   - Rating threshold
   - Verification status

4. Enrich store data:
   - Current operating status
   - Popular products
   - Recent reviews
   - Peak hours information

5. Rank stores based on:
   - Distance
   - Rating
   - Number of products
   - Operating status
   - Verification status

6. Return results with:
   - Store details
   - Distance and direction
   - Operating status
   - Key metrics
```

### GetStoreRecommendations(userId, location)
```
1. Gather user context:
   - Search history
   - Purchase history
   - Favorite stores
   - Preferred categories

2. Generate candidate stores:
   a. Location-based candidates:
      - Nearby stores within reasonable radius
      - New stores in area
   
   b. Similarity-based candidates:
      - Stores similar to user's favorites
      - Stores visited by similar users

3. Calculate recommendation scores:
   - Location relevance
   - Category match
   - User preference alignment
   - Store quality metrics
   - Novelty factor

4. Apply business rules:
   - Diversity in recommendations
   - Minimum quality thresholds
   - Operating hours
   - Special promotions

5. Return personalized recommendations with:
   - Recommendation reason
   - Key store information
   - Distance and directions
```

## 3. ProductTaggingService

### GenerateTagsFromImage(image)
```
1. Preprocess image:
   - Validate and normalize
   - Extract metadata

2. Run multiple ML models:
   a. Object detection:
      - Identify main objects
      - Detect attributes (color, size, style)
   
   b. Scene classification:
      - Identify context
      - Detect environment
   
   c. Text recognition (OCR):
      - Extract visible text
      - Identify brands/logos

3. Process ML outputs:
   - Aggregate detected elements
   - Filter irrelevant detections
   - Normalize detected terms

4. Generate hierarchical tags:
   - Primary category
   - Secondary categories
   - Attributes
   - Style descriptors
   - Brand information

5. Apply business rules:
   - Tag relevance scoring
   - Category-specific rules
   - Marketplace-specific terminology

6. Return structured output:
   - Hierarchical tags
   - Confidence scores
   - Suggested categories
```

## 4. LocationService

### CalculateDistance(location1, location2)
```
1. Validate inputs:
   - Verify coordinate formats
   - Check coordinate ranges

2. Convert coordinates:
   - Transform to radians
   - Handle coordinate system differences

3. Calculate distance:
   - Use Haversine formula for rough distance
   - If needed, refine with:
     * Vincenty formula for higher precision
     * Road network distance via mapping API

4. Apply corrections:
   - Elevation differences if relevant
   - Local geography factors
   - Known routing constraints

5. Return results:
   - Direct distance
   - Route distance (if calculated)
   - Accuracy level
```

### GetDirections(fromLocation, toLocation)
```
1. Validate locations:
   - Verify coordinates
   - Check accessibility

2. Determine transportation mode:
   - Walking
   - Driving
   - Public transit (if available)

3. Generate route options:
   - Query routing engine
   - Consider multiple paths
   - Account for:
     * Current traffic
     * Road closures
     * Time of day
     * Store hours

4. Optimize routes:
   - Balance distance vs. time
   - Consider user preferences
   - Account for local factors

5. Generate navigation data:
   - Turn-by-turn directions
   - Distance markers
   - Landmarks
   - Store entrance information

6. Return structured directions:
   - Multiple route options
   - ETA for each route
   - Key waypoints
   - Navigation cues
```
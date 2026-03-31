# Use Unsplash Documentation for further information

## Feed API spec

```bash
GET /photos?page={page}&per_page={perPage}&order_by={latest|oldest|popular}
Authorization: Client-ID <ACCESS_KEY>
Accept-Version: v1
```

### Success response

200 OK with a JSON array of photo objects. List endpoints return abbreviated objects, 
so fields may be fewer than GET /photos/:id

### Pagination headers

Unsplash says paginated endpoints include pagination info in headers, so your networking
layer should preserve response headers for future paging support.

### Image delivery rule

For feed images, use the returned urls.\* directly or derived from urls.raw while preserving 
the ixid parameter. Unsplash explicitly requires hotlinking returned image URLs.

### Example payload:

```json

[
  {
    "id": "LBI7cgq3pbM",
    "created_at": "2016-05-03T11:00:28-04:00",
    "updated_at": "2016-07-10T11:00:01-05:00",
    "width": 5245,
    "height": 3497,
    "color": "#60544D",
    "blur_hash": "LoC%a7IoIVxZ_NM|M{s:%hRjWAo0",
    "description": "A man drinking a coffee.",
    "alt_description": "man drinking coffee",
    "urls": {
      "raw": "https://images.unsplash.com/photo-...",
      "full": "https://images.unsplash.com/photo-...",
      "regular": "https://images.unsplash.com/photo-...",
      "small": "https://images.unsplash.com/photo-...",
      "thumb": "https://images.unsplash.com/photo-..."
    },
    "links": {
      "self": "https://api.unsplash.com/photos/LBI7cgq3pbM",
      "html": "https://unsplash.com/photos/LBI7cgq3pbM",
      "download": "https://unsplash.com/photos/LBI7cgq3pbM/download",
      "download_location": "https://api.unsplash.com/photos/LBI7cgq3pbM/download"
    },
    "user": {
      "id": "pXhwzz1JtQU",
      "username": "poorkane",
      "name": "Gilbert Kane",
      "portfolio_url": "https://example.com",
      "bio": "XO",
      "location": "Way out there",
      "instagram_username": "instantgrammer",
      "twitter_username": "crew",
      "profile_image": {
        "small": "https://images.unsplash.com/...",
        "medium": "https://images.unsplash.com/...",
        "large": "https://images.unsplash.com/..."
      },
      "links": {
        "self": "https://api.unsplash.com/users/poorkane",
        "html": "https://unsplash.com/poorkane",
        "photos": "https://api.unsplash.com/users/poorkane/photos",
        "portfolio": "https://api.unsplash.com/users/poorkane/portfolio"
      }
    }
  }
]

```


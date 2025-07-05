# Data Model Design

## Overview
This document describes the design decisions and implementation details for the HealthSync data models.

## Core Data Model: HealthMetric

### Design Principles
1. **Simplicity**: Single unified model for all health data
2. **Extensibility**: Easy to add new properties without breaking changes
3. **Portability**: JSON serializable for API integrations
4. **Consistency**: Standardized units and formats

### Property Definitions

#### Required Properties
- `id: UUID` - Unique identifier for each metric instance
- `name: String` - Human-readable name (e.g., "Heart Rate")
- `identifier: String` - Original HealthKit identifier for traceability
- `value: Double` - Numeric value in standardized unit
- `unit: String` - Standardized unit string (e.g., "bpm", "kg")
- `timestamp: Date` - When the measurement was taken
- `category: MetricCategory` - Classification for UI grouping

#### Optional Properties
- `source: String?` - Recording device/app (e.g., "Apple Watch")

### MetricCategory Enum

#### Categories
- **vitals**: Heart rate, blood pressure, respiratory rate, body temperature
- **activity**: Steps, distance, active energy, flights climbed
- **nutrition**: Dietary metrics, water intake, macronutrients
- **sleep**: Sleep analysis, sleep stages
- **lab**: Blood glucose, cholesterol, lab results
- **other**: Uncategorized or custom metrics

#### Extensibility
- New categories can be added without breaking existing code
- Unknown categories default to `.other`
- String raw values for JSON serialization

## Normalization Layer: MetricNormalizer

### Purpose
Convert diverse HealthKit data types into consistent HealthMetric objects.

### Key Responsibilities
1. **Unit Standardization**: Convert various units to standard forms
2. **Categorization**: Map HealthKit types to categories
3. **Name Mapping**: Convert technical identifiers to readable names
4. **Data Validation**: Ensure data integrity and handle edge cases

### Unit Standardization Rules

#### Common Conversions
- **Heart Rate**: Always in beats per minute (bpm)
- **Distance**: Always in meters (m)
- **Energy**: Always in kilocalories (kcal)
- **Weight**: Always in kilograms (kg)
- **Blood Pressure**: Always in mmHg
- **Temperature**: Always in Celsius (°C)

#### Rationale
- Consistent units simplify API integrations
- Reduces confusion in data visualization
- Enables proper data comparison across time
- Facilitates unit conversion in target systems

### Error Handling
- Invalid data types return nil (filtered out)
- Missing units default to empty string
- Timestamp errors use current date as fallback
- Source information is optional

## Testing Strategy

### Unit Tests
- HealthMetric serialization/deserialization
- MetricCategory enum functionality
- MetricNormalizer conversion accuracy
- Edge case handling (null values, invalid units)

### Integration Tests
- End-to-end conversion from HKSample to HealthMetric
- Category mapping validation
- Unit standardization verification
- Performance testing with large datasets

### Data Validation
- Ensure all required properties are populated
- Validate unit conversions are mathematically correct
- Verify timestamp handling across time zones
- Check source attribution accuracy

## Future Considerations

### Versioning
- Schema versioning for backward compatibility
- Migration strategies for model changes
- API versioning for external integrations

### Performance
- Lazy loading for large datasets
- Efficient batch processing
- Memory optimization for mobile devices
- Caching strategies for frequently accessed data

### Extensibility
- Custom metric types support
- User-defined categories
- Configurable unit preferences
- Metadata extension points

## Status: Pending Implementation
**Last Updated**: 2025-07-05
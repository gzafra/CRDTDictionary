# CRDTDictionary

Swift CRDT Dictionary implementation.

## Summary

Implementation of a CRDT Dictionary that allows conflict-free replication accross different systems by merging itself with other replicas.

Data validity is based on a Timestamp, last added element wins. Last-Write-Wins.


### Considerations

- Assumes there can't exist different values with same key in the dictionary. Adding a new value for an existing key will act as an update. If key-value pairs were needed to be unique combinations we would need to modify the dictionary to accept multiple `CRDTElement` per key and then filter out to get the one with the latest timestamp.

- Generic type needs to be specified when initializing the `CRDTDictionary`, if we wanted the dictionary to have different concrete types we could do at function level and let the caller infer the type.

- `CRDTElement` is exposed when retrieving elements from the dictionary but could be changed to key-value tuples.

- Added GMT Date extension as to unify timezones and prevent conflicting timezones when merging dictionaries from different devices.



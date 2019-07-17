#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Options for specifying a custom model. */
NS_SWIFT_NAME(ModelOptions)
@interface FIRModelOptions : NSObject

/** The name of a model downloaded from the server. */
@property(nonatomic, copy, readonly, nullable) NSString *remoteModelName;

/** The name of a model stored locally on the device. */
@property(nonatomic, copy, readonly, nullable) NSString *localModelName;

/**
 * Creates a new instance of `ModelOptions` with the given remote and/or local model name. At least
 * one model name must be provided. If both remote and local model names are provided, then the
 * remote model takes priority.
 *
 * @param remoteModelName The remote custom model name. Pass `nil` if only the provided local model
 *     name should be used.
 * @param localModelName The local custom model name. Pass `nil` if only the provided remote model
 *     name should be used.
 * @return Custom model options instance with the given model name(s).
 */
- (instancetype)initWithRemoteModelName:(nullable NSString *)remoteModelName
                         localModelName:(nullable NSString *)localModelName
    NS_DESIGNATED_INITIALIZER;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

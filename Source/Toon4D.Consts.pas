{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{     Copyright(c) 2025 Marco Geuze - GDK Software      }
{              All rights reserved                      }
{                                                       }
{              Licensed under MIT License               }
{                                                       }
{*******************************************************}
unit Toon4D.Consts;

interface

resourcestring
  ErrorInvalidJson = 'Invalid JSON input: %s';
  ErrorNilJsonValue = 'JSON value cannot be nil';
  ErrorConflictingOptions = 'Conflicting options specified: %s and %s';
  ErrorEncodingFailed = 'TOON encoding failed: %s';
  ErrorStrictValidation = 'Strict validation failed: %s';
  ErrorInvalidDelimiter = 'Invalid delimiter specified';
  ErrorInvalidIndentSize = 'Invalid indent size: %d (must be between 2 and 8)';

  InfoTokenReduction = 'Token reduction: %.1f%% (%d → %d tokens)';
  InfoArrayFormatDetected = 'Array format detected: %s';

implementation

end.

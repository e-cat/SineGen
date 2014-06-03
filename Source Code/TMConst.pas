unit TMConst;

interface

uses
  WaveFmt, TMKernel;

resourcestring
  SPowerCaptionOn = 'Power [is ON: %s]';
  SPowerCaptionOff = 'Power [is OFF]';
  SOn = 'On';
  SOff = 'Off';
  SPhaseDifferenceCaption = 'Difference';
  SPhaseDifferenceCaption1 = 'Difference: %.1f';
  SPhaseOffsetCaption = 'Offset';
  SPhaseOffsetCaption1 = 'Offset: %s';
  SOutputCaption = 'Output [%s]';
  SOutputCaptionUnknownFormat = 'Output - unknown format';
  SBufferTimeCaption = 'Buffer time: %d ms';
  SPrebufferTimeCaption = 'Pre-buffer time: %d ms';
  STimerCaption = 'Timer';
  STimerCaption1 = 'Timer [%s]';
  SOnNotify = '%s';
  SOffNotify = 'Off';
  SMacroAdding = 'Macro adding';
  SMacroListTooLong = 'List too long! Delete something.';
  SAboutCaption = 'About %s';


  STMSDispNameActive               = 'Active';
  STMSDispNameWorkFunction         = 'Work function';
  STMSDispNameFuncParams           = 'Function params';
  STMSDispNameLevel                = 'Level';
  STMSDispNameLevel_0              = 'Level 0';
  STMSDispNameLevel_1              = 'Level 1';
  STMSDispNameFrequency            = 'Frequency';
  STMSDispNameFrequencyDifference  = 'Frequency difference';
  STMSDispNamePhaseDifference      = 'Phase difference';
  STMSDispNamePhaseOffset          = 'Phase offset';
  STMSDispNameAMWorkFunction       = 'AM work function';
  STMSDispNameAMFuncParams         = 'AM function params';
  STMSDispNameAMLevel              = 'AM level';
  STMSDispNameAMFrequency          = 'AM frequency';
  STMSDispNameBMWorkFunction       = 'BM work function';
  STMSDispNameBMFuncParams         = 'BM function params';
  STMSDispNameBMLevel              = 'BM level';
  STMSDispNameBMFrequency          = 'BM frequency';
  STMSDispNameFMWorkFunction       = 'FM work function';
  STMSDispNameFMFuncParams         = 'FM function params';
  STMSDispNameFMLevel              = 'FM level';
  STMSDispNameFMFrequency          = 'FM frequency';
  STMSDispNamePDMWorkFunction      = 'PDM work function';
  STMSDispNamePDMFuncParams        = 'PDM function params';
  STMSDispNamePDMAmplitude         = 'PDM amplitude';
  STMSDispNamePDMFrequency         = 'PDM frequency';
  STMSDispNameTransitionTime       = 'Transition time';
  STMSDispNamePassageTime          = 'Passage time';
  STMSDispNameProgram              = 'Program';
  STMSDispNameProgramReverse       = 'Program reverse';
  STMSDispNameFadeIn               = 'Fade-in';
  STMSDispNameFadeOut              = 'Fade-out';
  STMSDispNameBufferTime           = 'Buffer time';
  STMSDispNamePrebufferTime        = 'Pre-buffer time';
  STMSDispNamePCMFormat            = 'PCM format';
  STMSDispNameDevice               = 'Device';
  STMSDispNameOutputFile           = 'Output file';

const
  STMSActive               = 'Active';
  STMSWorkFunction         = 'WorkFunction';
  STMSFuncParams           = 'FuncParams';
  STMSLevel                = 'Level';
  STMSLevel_0              = 'Level_0';
  STMSLevel_1              = 'Level_1';
  STMSFrequency            = 'Frequency';
  STMSFrequencyDifference  = 'FrequencyDifference';
  STMSPhaseDifference      = 'PhaseDifference';
  STMSPhaseOffset          = 'PhaseOffset';
  STMSAMWorkFunction       = 'AMWorkFunction';
  STMSAMFuncParams         = 'AMFuncParams';
  STMSAMLevel              = 'AMLevel';
  STMSAMFrequency          = 'AMFrequency';
  STMSBMWorkFunction       = 'BMWorkFunction';
  STMSBMFuncParams         = 'BMFuncParams';
  STMSBMLevel              = 'BMLevel';
  STMSBMFrequency          = 'BMFrequency';
  STMSFMWorkFunction       = 'FMWorkFunction';
  STMSFMFuncParams         = 'FMFuncParams';
  STMSFMLevel              = 'FMLevel';
  STMSFMFrequency          = 'FMFrequency';
  STMSPDMWorkFunction      = 'PDMWorkFunction';
  STMSPDMFuncParams        = 'PDMFuncParams';
  STMSPDMAmplitude         = 'PDMAmplitude';
  STMSPDMFrequency         = 'PDMFrequency';
  STMSTransitionTime       = 'TransitionTime';
  STMSPassageTime          = 'PassageTime';
  STMSProgram              = 'Program';
  STMSProgramReverse       = 'ProgramReverse';
  STMSFadeIn               = 'FadeIn';
  STMSFadeOut              = 'FadeOut';
  STMSBufferTime           = 'BufferTime';
  STMSPrebufferTime        = 'PrebufferTime';
  STMSPCMFormat            = 'PCMFormat';
  STMSDevice               = 'Device';
  STMSOutputFile           = 'OutputFile';


  TMSettingDispNames: array[TTMSetting] of string = (STMSDispNameActive,
    STMSDispNameWorkFunction, STMSDispNameFuncParams, STMSDispNameLevel,
    STMSDispNameLevel_0, STMSDispNameLevel_1, STMSDispNameFrequency,
    STMSDispNameFrequencyDifference, STMSDispNamePhaseDifference, STMSDispNamePhaseOffset,
    STMSDispNameAMWorkFunction, STMSDispNameAMFuncParams, STMSDispNameAMLevel,
    STMSDispNameAMFrequency, STMSDispNameBMWorkFunction,
    STMSDispNameBMFuncParams, STMSDispNameBMLevel, STMSDispNameBMFrequency,
    STMSDispNameFMWorkFunction, STMSDispNameFMFuncParams, STMSDispNameFMLevel,
    STMSDispNameFMFrequency, STMSDispNamePDMWorkFunction,
    STMSDispNamePDMFuncParams, STMSDispNamePDMAmplitude,
    STMSDispNamePDMFrequency, STMSDispNameTransitionTime,
    STMSDispNamePassageTime, STMSDispNameProgram, STMSDispNameProgramReverse,
    STMSDispNameFadeIn, STMSDispNameFadeOut, STMSDispNameBufferTime,
    STMSDispNamePrebufferTime, STMSDispNamePCMFormat, STMSDispNameDevice,
    STMSDispNameOutputFile, '', '');

  TMSettingNames: array[TTMSetting] of string = (STMSActive, STMSWorkFunction,
    STMSFuncParams, STMSLevel, STMSLevel_0, STMSLevel_1, STMSFrequency,
    STMSFrequencyDifference, STMSPhaseDifference, STMSPhaseOffset, STMSAMWorkFunction, STMSAMFuncParams,
    STMSAMLevel, STMSAMFrequency, STMSBMWorkFunction, STMSBMFuncParams,
    STMSBMLevel, STMSBMFrequency, STMSFMWorkFunction, STMSFMFuncParams,
    STMSFMLevel, STMSFMFrequency, STMSPDMWorkFunction, STMSPDMFuncParams,
    STMSPDMAmplitude, STMSPDMFrequency, STMSTransitionTime, STMSPassageTime,
    STMSProgram, STMSProgramReverse, STMSFadeIn, STMSFadeOut, STMSBufferTime,
    STMSPrebufferTime, STMSPCMFormat, STMSDevice, STMSOutputFile, '', '');

  SFormats          = 'Formats';
  {SMacroList        = 'MacroList';
  SSortIndex        = 'SortIndex';}
  SMinimizeToSNA    = 'MinimizeToSNA';
  STimeInMS = '%d ms';
  DefBufferTime   = 50;
  DefPreufferTime = 100;

var
  DefPCMFormats: TPCMFormats;

implementation

initialization
  SetLength(DefPCMFormats, 4);
                                
  DefPCMFormats[0].BitDepth := 24;
  DefPCMFormats[0].SamplingRate := 96000;
  DefPCMFormats[0].ChannelCount := 2;

  DefPCMFormats[1].BitDepth := 16;
  DefPCMFormats[1].SamplingRate := 48000;
  DefPCMFormats[1].ChannelCount := 2;

  DefPCMFormats[2].BitDepth := 16;
  DefPCMFormats[2].SamplingRate := 44100;
  DefPCMFormats[2].ChannelCount := 2;

  DefPCMFormats[3].BitDepth := 16;
  DefPCMFormats[3].SamplingRate := 48000;
  DefPCMFormats[3].ChannelCount := 1;

end.

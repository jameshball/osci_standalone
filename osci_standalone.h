/*
  ==============================================================================

   This file is part of the osci_standalone module
   Copyright (c) 2026 James H Ball

  ==============================================================================
*/

#pragma once

#include "osci_standalone_config.h"

/*******************************************************************************
 The block below describes the properties of this module, and is read by
 the Projucer to automatically generate project code that uses it.

 BEGIN_JUCE_MODULE_DECLARATION

  ID:                osci_standalone
  vendor:            jameshball
  version:           1.0.0
  name:              osci standalone
  description:       Shared JUCE standalone wrapper for osci apps
  website:           https://osci-render.com
  license:           GPLv3
  minimumCppStandard: 20

  dependencies:      juce_core, juce_audio_devices, juce_audio_plugin_client, juce_audio_processors, juce_audio_utils, juce_data_structures, juce_events, juce_gui_basics, juce_gui_extra, osci_audio_devices, osci_render_core

 END_JUCE_MODULE_DECLARATION

*******************************************************************************/

#include <juce_audio_devices/juce_audio_devices.h>
#include <juce_audio_plugin_client/juce_audio_plugin_client.h>
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_audio_utils/juce_audio_utils.h>
#include <juce_core/juce_core.h>
#include <juce_data_structures/juce_data_structures.h>
#include <juce_events/juce_events.h>
#include <juce_gui_basics/juce_gui_basics.h>
#include <juce_gui_extra/juce_gui_extra.h>
#include <osci_audio_devices/osci_audio_devices.h>
#include <osci_render_core/osci_render_core.h>

#include "standalone/osci_CustomStandaloneFilterWindow.h"


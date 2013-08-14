#==================================================================================================#
#                                                                                                  #
#  Copyright 2013 MaidSafe.net limited                                                             #
#                                                                                                  #
#  This MaidSafe Software is licensed under the MaidSafe.net Commercial License, version 1.0 or    #
#  later, and The General Public License (GPL), version 3. By contributing code to this project    #
#  You agree to the terms laid out in the MaidSafe Contributor Agreement, version 1.0, found in    #
#  the root directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also    #
#  available at:                                                                                   #
#                                                                                                  #
#    http://www.novinet.com/license                                                                #
#                                                                                                  #
#  Unless required by applicable law or agreed to in writing, software distributed under the       #
#  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       #
#  either express or implied. See the License for the specific language governing permissions      #
#  and limitations under the License.                                                              #
#                                                                                                  #
#==================================================================================================#


file(GLOB_RECURSE MetaFiles "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*.message_types.meta")
message("\${CMAKE_CURRENT_SOURCE_DIR} - ${CMAKE_CURRENT_SOURCE_DIR}")
message(FATAL_ERROR "\${MetaFiles} - ${MetaFiles}")

file(STRINGS message_types.cmake AllTypes)
foreach(MessageType ${AllTypes})
  string(REGEX REPLACE ".*Action:([^ ]*).*" "\\1" Action "${MessageType}")
  string(REGEX REPLACE ".*Source:([^ ]*).*" "\\1" Source "${MessageType}")
  string(REGEX MATCH "[^:]+" SourcePersona "${Source}")
  string(REGEX REPLACE "[^:]+:(.*)" "\\1" RoutingSenderType "${Source}")
  string(REGEX REPLACE ".*Destination:([^ ]*).*" "\\1" Destination "${MessageType}")
  string(REGEX MATCH "[^:]+" DestinationPersona "${Destination}")
  string(REGEX REPLACE "[^:]+:(.*)" "\\1" RoutingReceiverType "${Destination}")
  string(REGEX REPLACE ".*Contents:([^ ]*).*" "\\1" Contents "${MessageType}")
  string(REGEX MATCH "HasResponse" HasResponse "${MessageType}")
  
  list(APPEND DestinationPersonas ${DestinationPersona})
  list(APPEND ${DestinationPersona}ServiceMessages "${Action}:${SourcePersona}")

  set(Typedef "// Auto-generated typedef.  Modify in nfs/cmake/message_types.cmake if required, not here.\n")
  list(APPEND Typedef "typedef MessageWrapper<\n")
  list(APPEND Typedef "    MessageAction::k${Action},\n")
  list(APPEND Typedef "    SourcePersona<Persona::k${SourcePersona}>,\n")
  list(APPEND Typedef "    routing::${RoutingSenderType}Source,\n")
  list(APPEND Typedef "    DestinationPersona<Persona::k${DestinationPersona}>,\n")
  list(APPEND Typedef "    routing::${RoutingReceiverType}Id,\n")
  list(APPEND Typedef "    ${Contents}> ${Action}From${SourcePersona}To${DestinationPersona};\n\n")

  list(APPEND Typedefs "${Typedef}")
endforeach()

list(REMOVE_DUPLICATES DestinationPersonas)
string(REPLACE "\n;" "\n" Typedefs "${Typedefs}")

foreach(DestinationPersona ${DestinationPersonas})
  unset(Actions)
#  list(SORT ${DestinationPersona}ServiceMessages)
  foreach(MessageType ${${DestinationPersona}ServiceMessages})
    string(REGEX MATCH "[^:]+" Action "${MessageType}")
    list(APPEND Actions ${Action})
    unset(${Action}Sources)
    unset(AllMessageTypedefs)
  endforeach()
  list(REMOVE_DUPLICATES Actions)
  foreach(MessageType ${${DestinationPersona}ServiceMessages})
    string(REGEX MATCH "[^:]+" Action "${MessageType}")
    string(REGEX REPLACE "[^:]+:(.*)" "\\1" SourcePersona "${MessageType}")
    list(APPEND ${Action}Sources ${SourcePersona})
    list(APPEND AllMessageTypedefs ${Action}From${SourcePersona}To${DestinationPersona})
  endforeach()

  string(REGEX REPLACE ";" ",\n    " AllMessageTypedefs "${AllMessageTypedefs}")
  set(Variant "//==================================================================================================\n")
  list(APPEND Variant "// ${DestinationPersona}\n")
  list(APPEND Variant "//==================================================================================================\n\n")

  list(APPEND Variant "// Auto-generated typedef.  Modify in nfs/cmake/message_types.cmake if required, not here.\n")
  list(APPEND Variant "typedef boost::variant<\n    ${AllMessageTypedefs}> ${DestinationPersona}ServiceMessages;\n\n")
  
  list(APPEND Variant "// Auto-generated function.  Modify in nfs/cmake/message_types.cmake if required, not here.\n")
  list(APPEND Variant "void GetVariant(const TypeErasedMessageWrapper& message,\n")
  list(APPEND Variant "                ${DestinationPersona}ServiceMessages& variant) {\n")
  list(APPEND Variant "  auto action(std::get<0>(message));\n")
  list(APPEND Variant "  auto source_persona(std::get<1>(message).data);\n")
  list(APPEND Variant "  auto destination_persona(std::get<2>(message).data);\n")
  list(APPEND Variant "  if (destination_persona != Persona::k${DestinationPersona}) {\n")
  list(APPEND Variant "    LOG(kError) << \"Wrong destination persona type: \" << static_cast<int32_t>(destination_persona);\n")
  list(APPEND Variant "    ThrowError(CommonErrors::invalid_parameter);\n")
  list(APPEND Variant "  }\n")
  list(APPEND Variant "  switch (action) {\n")
  foreach(Action ${Actions})
    list(APPEND Variant "    case MessageAction::k${Action}:\n")
    list(APPEND Variant "      switch (source_persona) {\n")
    foreach(SourcePersona ${${Action}Sources})
      list(APPEND Variant "        case Persona::k${SourcePersona}:\n")
      list(APPEND Variant "          variant = ${DestinationPersona}ServiceMessages(\n")
      list(APPEND Variant "              ${Action}From${SourcePersona}To${DestinationPersona}(message));\n")
      list(APPEND Variant "          break;\n")
    endforeach()
    list(APPEND Variant "        default:\n")
    list(APPEND Variant "          LOG(kError) << \"Wrong source persona type: \" << static_cast<int32_t>(source_persona);\n")
    list(APPEND Variant "          ThrowError(CommonErrors::invalid_parameter);\n")
    list(APPEND Variant "      }\n")
    list(APPEND Variant "      break;\n")
  endforeach()
  list(APPEND Variant "    default:\n")
  list(APPEND Variant "      LOG(kError) << \"Wrong action type: \" << static_cast<int32_t>(action);\n")
  list(APPEND Variant "      ThrowError(CommonErrors::invalid_parameter);\n")
  list(APPEND Variant "  }\n")
  list(APPEND Variant "}\n\n\n")

  list(APPEND Variants "${Variant}")
endforeach()
string(REPLACE "\n;" "\n" Variants "${Variants}")

configure_file(${InputFile} ${OutputFile} @ONLY)

/* Copyright 2013 MaidSafe.net limited

This MaidSafe Software is licensed under the MaidSafe.net Commercial License, version 1.0 or later,
and The General Public License (GPL), version 3. By contributing code to this project You agree to
the terms laid out in the MaidSafe Contributor Agreement, version 1.0, found in the root directory
of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also available at:

http://www.novinet.com/license

Unless required by applicable law or agreed to in writing, software distributed under the License is
distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing permissions and limitations under the
License.
*/

#include "maidsafe/nfs/client/maid_node_dispatcher.h"


namespace maidsafe {

namespace nfs_client {

MaidNodeDispatcher::MaidNodeDispatcher(routing::Routing& routing)
    : routing_(routing),
      kThisNodeAsSender_(routing_.kNodeId()),
      kMaidManagerReceiver_(routing_.kNodeId()) {}

void MaidNodeDispatcher::SendCreateAccountRequest(routing::TaskId task_id) {
  typedef nfs::CreateAccountRequestFromMaidNodeToMaidManager NfsMessage;
  CheckSourcePersonaType<NfsMessage>();
  typedef routing::Message<NfsMessage::Sender, NfsMessage::Receiver> RoutingMessage;
  NfsMessage nfs_message(nfs::MessageId(task_id), (NfsMessage::Contents()));
  routing_.Send(RoutingMessage(nfs_message.Serialise(), kThisNodeAsSender_, kMaidManagerReceiver_));
}

void MaidNodeDispatcher::SendRemoveAccountRequest(routing::TaskId task_id) {
  typedef nfs::RemoveAccountRequestFromMaidNodeToMaidManager NfsMessage;
  CheckSourcePersonaType<NfsMessage>();
  typedef routing::Message<NfsMessage::Sender, NfsMessage::Receiver> RoutingMessage;
  NfsMessage nfs_message(nfs::MessageId(task_id), (NfsMessage::Contents()));
  routing_.Send(RoutingMessage(nfs_message.Serialise(), kThisNodeAsSender_, kMaidManagerReceiver_));
}

void MaidNodeDispatcher::SendRegisterPmidRequest(
    routing::TaskId task_id,
    const nfs_vault::PmidRegistration& pmid_registration) {
  typedef nfs::RegisterPmidRequestFromMaidNodeToMaidManager NfsMessage;
  CheckSourcePersonaType<NfsMessage>();
  assert(!pmid_registration.unregister());
  typedef routing::Message<NfsMessage::Sender, NfsMessage::Receiver> RoutingMessage;
  NfsMessage nfs_message(nfs::MessageId(task_id), pmid_registration);
  routing_.Send(RoutingMessage(nfs_message.Serialise(), kThisNodeAsSender_, kMaidManagerReceiver_));
}

void MaidNodeDispatcher::SendUnregisterPmidRequest(
    routing::TaskId task_id,
    const nfs_vault::PmidRegistration& pmid_registration) {
  typedef nfs::UnregisterPmidRequestFromMaidNodeToMaidManager NfsMessage;
  CheckSourcePersonaType<NfsMessage>();
  assert(pmid_registration.unregister());
  typedef routing::Message<NfsMessage::Sender, NfsMessage::Receiver> RoutingMessage;
  NfsMessage nfs_message(nfs::MessageId(task_id), pmid_registration);
  routing_.Send(RoutingMessage(nfs_message.Serialise(), kThisNodeAsSender_, kMaidManagerReceiver_));
}

void MaidNodeDispatcher::SendGetPmidHealthRequest(const passport::Pmid& pmid) {
  typedef nfs::GetPmidHealthRequestFromMaidNodeToMaidManager NfsMessage;
  CheckSourcePersonaType<NfsMessage>();
  typedef routing::Message<NfsMessage::Sender, NfsMessage::Receiver> RoutingMessage;
  NfsMessage nfs_message(NfsMessage::Contents(pmid.name()));
  routing_.Send(RoutingMessage(nfs_message.Serialise(), kThisNodeAsSender_, kMaidManagerReceiver_));
}

}  // namespace nfs_client

}  // namespace maidsafe

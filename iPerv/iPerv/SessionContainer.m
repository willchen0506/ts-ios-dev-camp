/*
     File: SessionContainer.m
 Abstract:  This container class is used to encapsulate the Multipeer Connectivity API classes and their respective delegate callbacks.  The is the MOST IMPORTANT source file in the entire example.  In this class you see examples of managing MCSession state, sending and receving data based messages, and sending and receving URL resources via the convenience API. 
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

@import MultipeerConnectivity;

#import "SessionContainer.h"

@interface SessionContainer()
// Framework UI class for handling incoming invitations
@property (retain, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic, readonly) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (nonatomic, readonly) MCNearbyServiceAdvertiser *serviceAdvertiser;
@end

@implementation SessionContainer

// Session container designated initializer
- (id)initWithDisplayName:(NSString *)displayName serviceType:(NSString *)serviceType
{
    if (self = [super init]) {
        // Create the peer ID with user input display name.  This display name will be seen by other browsing peers
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        // Create the session that peers will be invited/join into.  You can provide an optinal security identity for custom authentication.  Also you can set the encryption preference for the session.
        _session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        // Set ourselves as the MCSessionDelegate
        _session.delegate = self;
        // Create the advertiser assistant for managing incoming invitation
//        _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:serviceType discoveryInfo:nil session:_session];
        // Start the assistant to begin advertising your peers availability
//        [_advertiserAssistant start];
        
        _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID
                                                               discoveryInfo:nil
                                                                 serviceType:serviceType];
        _serviceAdvertiser.delegate = self;
        
        _nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID
                                                                 serviceType:serviceType];
        _nearbyServiceBrowser.delegate = self;
        [self start];
    }
    return self;
}

- (void)start {
//    [_serviceAdvertiser startAdvertisingPeer];
    [_nearbyServiceBrowser startBrowsingForPeers];
}

- (void)stop {
//    [_serviceAdvertiser stopAdvertisingPeer];
    [_nearbyServiceBrowser stopBrowsingForPeers];
}


// On dealloc we should clean up the session by disconnecting from it.
- (void)dealloc
{
    [_advertiserAssistant stop];
    [_session disconnect];
}

// Helper method for human readable printing of MCSessionState.  This state is per peer.
- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected";

        case MCSessionStateConnecting:
            return @"Connecting";

        case MCSessionStateNotConnected:
            return @"Not Connected";
    }
}

#pragma mark - Public methods

// Instance method for sending a string bassed text message to all remote peers
- (void)sendMessage:(NSString *)message
{
    // Convert the string into a UTF8 encoded data
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    // Send text message to all connected peers
    NSError *error;
    [self.session sendData:messageData toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error) {
        NSLog(@"Error sending message to peers %@", error);
    }
    else {
        NSLog(@"Success");
    }
}

- (void)sendData:(NSData *)data
{
    // Send text message to all connected peers
    NSError *error;
    NSLog(@"%@", self.session.connectedPeers);
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error) {
        NSLog(@"Error sending message to peers %@", error);
    }
    else {
        NSLog(@"Success");
    }
}


// Method for sending image resources to all connected remote peers.  Returns an progress type transcript for monitoring tranfer
- (void)sendImage:(NSURL *)imageUrl
{
    NSProgress *progress;
    // Loop on connected peers and send the image to each
    for (MCPeerID *peerID in _session.connectedPeers) {
//        imageUrl = [NSURL URLWithString:@"http://images.apple.com/home/images/promo_logic_pro.jpg"];
        // Send the resource to the remote peer.  The completion handler block will be called at the end of sending or if any errors occur
        progress = [self.session sendResourceAtURL:imageUrl withName:[imageUrl lastPathComponent] toPeer:peerID withCompletionHandler:^(NSError *error) {
            // Implement this block to know when the sending resource transfer completes and if there is an error.
            if (error) {
                NSLog(@"Send resource to peer [%@] completed with Error [%@]", peerID.displayName, error);
            }
            else {
            }
        }];
    }
}

#pragma mark - MCSessionDelegate methods

// Override this method to handle changes to peer session state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
    [self.delegate statusChanged:[self stringForPeerConnectionState:state]];
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Notify the delegate that we have received a new chunk of data from a peer
    [self.delegate receivedData:data];
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    // Create a resource progress transcript
    // Notify the UI delegate
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    // If error is not nil something went wrong
    if (error)
    {
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], resourceName];
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
        }
        else {
            // Get a URL for the path we just copied the resource to
            NSURL *imageUrl = [NSURL fileURLWithPath:copyPath];
            // Create an image transcript for this received image resource
        }
    }
}

// Streaming API not utilized in this sample code
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Received data over stream with name %@ from peer %@", streamName, peerID.displayName);
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    NSLog(@"FOUND PEER");
    [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:10.0f];

}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LOST PEER");
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"DID NOT START BROWSING");
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler

{
    
    NSLog(@"receive invitation from peer: %@", peerID.displayName);
    
    invitationHandler(YES, self.session);
//    [_serviceAdvertiser stopAdvertisingPeer];
//    [_nearbyServiceBrowser stopBrowsingForPeers];
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
}

@end

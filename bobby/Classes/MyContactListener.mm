//
//  MyContactListener.m
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

//#import "Path.h"
#import "MyContactListener.h"

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
}

void MyContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) 
{
	
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	
	CCNode *node1 = (CCNode *)bodyA->GetUserData();
	CCNode *node2 = (CCNode *)bodyB->GetUserData();
	
	
	if (node1.tag == ObjectTypeRemoving || node2.tag == ObjectTypeRemoving || node1.tag == ObjectTypeInactive || node2.tag == ObjectTypeInactive)
	{
		//TRACE(@"disable tag: %d %d", node1.tag, node2.tag);
		contact->SetEnabled(false);
		return;
	}
	
	contact->SetEnabled(true);
/*
	b2Vec2 position = m_character->GetBody()->GetPosition();
	
	if (position.y < m_top + m_radius - 3.0f * b2_linearSlop)
	{
		contact->SetEnabled(false);
	}*/
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}


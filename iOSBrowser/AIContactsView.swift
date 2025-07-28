//
//  AIContactsView.swift
//  iOSBrowser
//
//  简化的AI联系人视图 - 避免编译问题
//

import SwiftUI

struct AIContactsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("AI联系人")
                    .font(.title)
                    .padding()
                
                Text("此功能已迁移到AI聊天tab")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("AI联系人")
        }
    }
}

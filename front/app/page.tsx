"use client";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Shield, Clock, Users, Code, Database, Link } from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center space-x-2">
              <div className="h-8 w-8 rounded-lg bg-primary flex items-center justify-center">
                <Clock className="h-5 w-5 text-primary-foreground" />
              </div>
              <span className="font-bold text-xl font-sans text-foreground">
                The Persistence of Memory
              </span>
            </div>
            <nav className="hidden md:flex items-center space-x-8">
              <a
                href="#features"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                Features
              </a>
              <a
                href="#how-it-works"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                How It Works
              </a>
              <a
                href="#developers"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                For Developers
              </a>
              <Button variant="outline" size="sm">
                Contact
              </Button>
            </nav>
            <Button className="bg-primary hover:bg-primary/90 text-primary-foreground">
              Get Started
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative py-20 lg:py-32 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-background to-secondary/5"></div>
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 relative">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold font-sans text-foreground mb-6 leading-tight">
              Easily save your posts from your favorite social media.
              <br />
              <span className="text-primary">Prove they&apos;re yours.</span>
              <br />
              Forever.
            </h1>
            <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto leading-relaxed">
              A simple tool to anchor your favorite posts and content to the
              blockchain, so no platform can ever erase them.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button
                size="lg"
                className="bg-primary hover:bg-primary/90 text-primary-foreground text-lg px-8 py-3"
              >
                Start a Proof
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="text-lg px-8 py-3 bg-transparent"
              >
                Explore Features
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-muted/30">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold font-sans text-foreground mb-4">
              Preserve What Matters Most
            </h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Simple, secure, and built for everyone. No blockchain knowledge
              required.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="border-border bg-card hover:shadow-lg transition-shadow">
              <CardHeader className="text-center">
                <div className="mx-auto mb-4 h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center">
                  <Shield className="h-6 w-6 text-primary" />
                </div>
                <CardTitle className="font-sans">
                  Anchor your memories
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-center">
                  Save a cryptographic fingerprint of your content on-chain in
                  one click.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="border-border bg-card hover:shadow-lg transition-shadow">
              <CardHeader className="text-center">
                <div className="mx-auto mb-4 h-12 w-12 rounded-lg bg-secondary/10 flex items-center justify-center">
                  <Users className="h-6 w-6 text-secondary" />
                </div>
                <CardTitle className="font-sans">
                  Prove it&apos;s yours
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-center">
                  Verify your identity by posting a short code in your social
                  profile.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="border-border bg-card hover:shadow-lg transition-shadow">
              <CardHeader className="text-center">
                <div className="mx-auto mb-4 h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center">
                  <Link className="h-6 w-6 text-primary" />
                </div>
                <CardTitle className="font-sans">
                  No new network to join
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-center">
                  Keep using Instagram, Twitter, etc. This app adds an invisible
                  layer of ownership.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="border-border bg-card hover:shadow-lg transition-shadow">
              <CardHeader className="text-center">
                <div className="mx-auto mb-4 h-12 w-12 rounded-lg bg-secondary/10 flex items-center justify-center">
                  <Clock className="h-6 w-6 text-secondary" />
                </div>
                <CardTitle className="font-sans">
                  Built for the future
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-center">
                  Your content can later become NFTs, memorials, or part of
                  digital legacy apps.
                </CardDescription>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold font-sans text-foreground mb-4">
              How It Works
            </h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Three simple steps to preserve your digital memories forever.
            </p>
          </div>
          <div className="max-w-4xl mx-auto">
            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="mx-auto mb-6 h-16 w-16 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-2xl font-bold">
                  1
                </div>
                <h3 className="text-xl font-semibold font-sans mb-3">
                  Connect Your Content
                </h3>
                <p className="text-muted-foreground">
                  Simply paste the URL of your Instagram post, tweet, or any
                  social media content you want to preserve.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto mb-6 h-16 w-16 rounded-full bg-secondary text-secondary-foreground flex items-center justify-center text-2xl font-bold">
                  2
                </div>
                <h3 className="text-xl font-semibold font-sans mb-3">
                  Verify Ownership
                </h3>
                <p className="text-muted-foreground">
                  Post a unique verification code to your profile to prove the
                  content belongs to you.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto mb-6 h-16 w-16 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-2xl font-bold">
                  3
                </div>
                <h3 className="text-xl font-semibold font-sans mb-3">
                  Anchor Forever
                </h3>
                <p className="text-muted-foreground">
                  Your content&apos;s fingerprint is stored on the blockchain,
                  creating an immutable record of your memory.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Technical Section for Developers */}
      <section id="developers" className="py-20 bg-muted/30">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              <h2 className="text-3xl sm:text-4xl font-bold font-sans text-foreground mb-4">
                For Developers / Curious Minds
              </h2>
              <p className="text-xl text-muted-foreground">
                Built on open standards with composable architecture.
              </p>
            </div>
            <div className="grid md:grid-cols-2 gap-8">
              <Card className="border-border bg-card">
                <CardHeader>
                  <div className="flex items-center space-x-2 mb-2">
                    <Database className="h-5 w-5 text-primary" />
                    <CardTitle className="font-sans">
                      On-Chain Storage
                    </CardTitle>
                  </div>
                </CardHeader>
                <CardContent>
                  <ul className="space-y-2 text-muted-foreground">
                    <li>• Anchors stored on EVM-compatible chains</li>
                    <li>• Cryptographic hashes ensure content integrity</li>
                    <li>• Gas-optimized smart contracts</li>
                    <li>• Supports multiple blockchain networks</li>
                  </ul>
                </CardContent>
              </Card>

              <Card className="border-border bg-card">
                <CardHeader>
                  <div className="flex items-center space-x-2 mb-2">
                    <Code className="h-5 w-5 text-secondary" />
                    <CardTitle className="font-sans">
                      Identity Verification
                    </CardTitle>
                  </div>
                </CardHeader>
                <CardContent>
                  <ul className="space-y-2 text-muted-foreground">
                    <li>• Signed message verification</li>
                    <li>• Social media profile validation</li>
                    <li>• Zero-knowledge proof options</li>
                    <li>• Multi-platform identity linking</li>
                  </ul>
                </CardContent>
              </Card>
            </div>
            <div className="text-center mt-8">
              <Button
                variant="outline"
                size="lg"
                className="mr-4 bg-transparent"
              >
                View Documentation
              </Button>
              <Button
                variant="outline"
                size="lg"
                onClick={() =>
                  window.open(
                    "https://github.com/garosan/ethglobal_nyc_2025",
                    "_blank"
                  )
                }
              >
                GitHub Repository
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Final CTA Section */}
      <section className="py-20 bg-gradient-to-r from-primary/10 via-background to-secondary/10">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold font-sans text-foreground mb-6">
            Don&apos;t let your memories vanish.
            <br />
            Start your first proof today.
          </h2>
          <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
            Join thousands of users who have already secured their digital
            legacy on the blockchain.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button
              size="lg"
              className="bg-primary hover:bg-primary/90 text-primary-foreground text-lg px-8 py-3"
            >
              Start a Proof
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="text-lg px-8 py-3 bg-transparent"
            >
              Explore Features
            </Button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-border bg-muted/30 py-12">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8">
            <div className="col-span-2">
              <div className="flex items-center space-x-2 mb-4">
                <div className="h-8 w-8 rounded-lg bg-primary flex items-center justify-center">
                  <Clock className="h-5 w-5 text-primary-foreground" />
                </div>
                <span className="font-bold text-xl font-sans text-foreground">
                  The Persistence of Memory
                </span>
              </div>
              <p className="text-muted-foreground mb-4 max-w-md">
                Preserving your digital memories with the power of blockchain
                technology.
              </p>
            </div>
            <div>
              <h3 className="font-semibold font-sans text-foreground mb-4">
                Product
              </h3>
              <ul className="space-y-2 text-muted-foreground">
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    Features
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    How It Works
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    Pricing
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    FAQ
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold font-sans text-foreground mb-4">
                Company
              </h3>
              <ul className="space-y-2 text-muted-foreground">
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    Privacy Policy
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    Terms of Service
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    GitHub
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="hover:text-foreground transition-colors"
                  >
                    Contact
                  </a>
                </li>
              </ul>
            </div>
          </div>
          <div className="border-t border-border mt-8 pt-8 text-center text-muted-foreground">
            <p>&copy; 2025 The Persistence of Memory. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

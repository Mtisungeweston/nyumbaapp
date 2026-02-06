import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

export default function Page() {
  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Nyumba Housing App</CardTitle>
          <CardDescription>Mobile housing marketplace for Malawi</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-muted-foreground">
            This is the Flutter mobile application for Nyumba - a housing marketplace platform.
          </p>
          <div className="space-y-2">
            <h3 className="font-semibold text-sm">Features:</h3>
            <ul className="text-sm text-muted-foreground space-y-1 list-disc list-inside">
              <li>Property listings and search</li>
              <li>Direct landlord/tenant messaging</li>
              <li>User authentication with OTP</li>
              <li>Firebase integration</li>
              <li>Real-time notifications</li>
            </ul>
          </div>
          <div className="pt-4">
            <p className="text-xs text-muted-foreground">
              For the mobile app, build and deploy the Flutter application to Android devices using the instructions in <code className="bg-muted px-1 rounded">FLUTTER_SETUP.md</code>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package receiver.cli;
import com.rabbitmq.client.*;

import java.io.IOException;
/**
 *
 * @author akhfa
 * Comments:
 *      Menerima pesan dari rabbitmq dengan param:
 *      0. host
 *      1. virtualhost
 *      2. username
 *      3. password
 *      4. exchange name
 *      5. queue name
 */
public class ReceiverCli {

  public static void main(String[] argv) throws Exception {
    ConnectionFactory factory = new ConnectionFactory();
    factory.setHost(argv[0]);
    factory.setUsername(argv[2]);
    factory.setPassword(argv[3]);
    factory.setVirtualHost(argv[1]);
    final Connection connection = factory.newConnection();
    final Channel channel = connection.createChannel();
    
    //                      exchange name, type, durable
    channel.exchangeDeclare(argv[4], "fanout", true);

    channel.queueDeclare(argv[5], false, false, false, null);
    System.out.println(" [*] Waiting for messages. To exit press CTRL+C");

    channel.basicQos(1);

    final Consumer consumer = new DefaultConsumer(channel) {
      @Override
      public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
        String message = new String(body, "UTF-8");

        System.out.println(" [x] Received '" + message + "'");
        try {
          doWork(message);
        } finally {
          System.out.println(" [x] Done");
          channel.basicAck(envelope.getDeliveryTag(), false);
        }
      }
    };
    channel.basicConsume(argv[4], false, consumer);
  }

  private static void doWork(String task) {
    for (char ch : task.toCharArray()) {
      if (ch == '.') {
        try {
          Thread.sleep(1000);
        } catch (InterruptedException _ignored) {
          Thread.currentThread().interrupt();
        }
      }
    }
  }
    
}

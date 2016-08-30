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
 *      1. exchange name
 *      2. queue name
 */
public class ReceiverCli {

  public static void main(String[] argv) throws Exception {
    ConnectionFactory factory = new ConnectionFactory();
    factory.setHost("rabbitmq.akhfa.me");
    factory.setUsername("ta");
    factory.setPassword("BuatTA");
    factory.setVirtualHost("ta");
    final Connection connection = factory.newConnection();
    final Channel channel = connection.createChannel();
    
    //                      exchange name, type, durable
    channel.exchangeDeclare(argv[0], "fanout", true);

    System.err.println(argv[0]);
    
    channel.queueDeclare(argv[1], false, false, false, null);
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
    channel.basicConsume(argv[0], false, consumer);
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
